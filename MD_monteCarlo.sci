funcprot(0);
clear;
clc;

//================ PARAMETERS ==================

N   = 80;      
rho = 0.2;     
T   = 1.0;     
beta = 1/T;

r_cut = 2.5;
rc2   = r_cut^2;

n_steps = 150000;
max_disp = 0.15;

// simulation box
Vol = N / rho;
L   = Vol^(1/3);

//================ INITIAL LATTICE ==================

n_side = ceil(N^(1/3));
spacing = L / n_side;

pos = zeros(N,3);
idx = 1;

for ix = 0:n_side-1
for iy = 0:n_side-1
for iz = 0:n_side-1

    if idx <= N then
        pos(idx,:) = ([ix iy iz] + 0.5) * spacing;
        idx = idx + 1;
    end

end
end
end


//================ DISTANCE WITH PBC ==================

function r2 = dist2_pbc(ri,rj,L)
    dr = ri - rj;
    dr = dr - L * round(dr./L);
    r2 = sum(dr.^2);
endfunction


//================ LJ PAIR POTENTIAL ==================

function u = lj_pair(r2)
    r2i = 1/r2;
    r6i = r2i^3;
    u = 4 * r6i * (r6i - 1);
endfunction


//================ TOTAL ENERGY ==================

function E = total_energy(pos,N,L,rc2)
    E = 0;
    for i = 1:N-1
    for j = i+1:N
        r2 = dist2_pbc(pos(i,:),pos(j,:),L);
        if r2 < rc2 then
            E = E + lj_pair(r2);
        end
    end
    end
endfunction


//================ PARTICLE ENERGY ==================

function e_i = particle_energy(i,ri,pos,N,L,rc2)
    e_i = 0;
    for j = 1:N
        if j <> i then
            r2 = dist2_pbc(ri,pos(j,:),L);
            if r2 < rc2 then
                e_i = e_i + lj_pair(r2);
            end
        end
    end
endfunction


//================ INITIAL ENERGY ==================

E_current = total_energy(pos,N,L,rc2);


//================ MONTE CARLO ==================

n_accept = 0;

fp = mopen("energy_output.txt","wt");
mfprintf(fp,"Step Energy\n");

for step = 1:n_steps

    // pick random particle
    i = grand(1,1,"uin",1,N);

    // trial displacement
    delta = (rand(1,3)-0.5)*2*max_disp;

    ri_old = pos(i,:);
    ri_new = ri_old + delta;

    // wrap inside box
    ri_new = ri_new - L * floor(ri_new./L);

    // energy difference
    e_old = particle_energy(i,ri_old,pos,N,L,rc2);
    e_new = particle_energy(i,ri_new,pos,N,L,rc2);

    dE = e_new - e_old;

    // Metropolis criterion
    if (dE < 0) | (rand() < exp(-beta*dE)) then
        pos(i,:) = ri_new;
        E_current = E_current + dE;
        n_accept = n_accept + 1;
    end

    // save energy
    mfprintf(fp,"%d %f\n",step,E_current);

    // progress print (fixed bug)
    if modulo(step,N) == 0 then
        printf("Step %d / %d\n",step,n_steps);
    end

end

mclose(fp);


//================ RESULTS ==================

acc_rate = (n_accept / n_steps) * 100;

printf("\nAcceptance rate : %.2f %%\n",acc_rate);
printf("Energy per particle : %f\n",E_current/N);


//================ PLOT ==================

data = fscanfMat("energy_output.txt");

scf(0);
clf();
plot(data(:,1),data(:,2)/N);
xlabel("MC Steps");
ylabel("Energy per particle");
title("Lennard-Jones Monte Carlo Simulation");
