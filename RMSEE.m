%Code For calculating the Root mean sq. error.

function [rmse]=RMSEE(actual_data,calculated_data)

[r,c]=size(actual_data);
rmse=sqrt(mean((actual_data(:)-calculated_data(:)).^2));

rmse=rmse/(r*c);

end
