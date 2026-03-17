funcprot(0);
clear();
clc();
//monte carlo
//side and number of total count
side = 1; //side of square
max_step = 100000;//max number of points
step = 100;//min and increase of points
count_vals = step:step:max_step;//number of point count
value_pi = zeros(1,length(count_vals)); //value of pis

sav_pi = mopen("D:\ScilabCodes\monte_calo_MD\val_pi","wt");

for i = 1:length(count_vals)
    count = 0;
    N = count_vals(i);
    x = rand(1,N);
    y = rand(1,N);
    
    for j = 1:N
      d = x(j)^2 + y(j)^2;
        if d <= 1 then
            count = count + 1;
        end
    end
    value_pi(i) = 4*count/N;
    mfprintf(sav_pi,"%10.4f  %10.4f\n",N,value_pi(i))
end





plot(count_vals,value_pi);
xlabel("Number of MC shots");
ylabel("Pi");





