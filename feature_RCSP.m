function [SpatialFilter]=feature_RCSP(TargetTrainData, TargetTrainDataLabel, GenericTrainData, GenericTrainDataLabel, number, beta, gamma)

m = round(number/2);              % 选取的最大、最小特征值的个数

target_size =size(TargetTrainData,1);
other_size=size(GenericTrainData,1);
I = eye(target_size);
target_c1 = zeros(target_size); 
target_c2 = zeros(target_size);
other_c1 = zeros(other_size);
other_gc2 = zeros(other_size);

difflabel = diffnum(TargetTrainDataLabel);  

target_index1 = find(TargetTrainDataLabel==difflabel(1)); 
target_index2 = find(TargetTrainDataLabel==difflabel(2)); 
target_num1 = size(target_index1,1); 
target_num2 = size(target_index2,1);

other_index1 = find(GenericTrainDataLabel==difflabel(1)); 
other_index2 = find(GenericTrainDataLabel==difflabel(2)); 
other_num1 = size(other_index1,1); 
other_num2 = size(other_index2,1);

for j = 1:target_num1
    tmp = TargetTrainData(:,:,target_index1(j))*TargetTrainData(:,:,target_index1(j))';
    target_c1 = target_c1 + tmp./trace(tmp);    
end
for j = 1:target_num2
    tmp = TargetTrainData(:,:,target_index2(j))*TargetTrainData(:,:,target_index2(j))';
    target_c2 = target_c2 + tmp./trace(tmp);    
end
for j = 1:other_num1
    tmp = GenericTrainData(:,:,other_index1(j))*GenericTrainData(:,:,other_index1(j))';
    other_c1 = other_c1 + tmp./trace(tmp);    
end
for j = 1:other_num2
    tmp = GenericTrainData(:,:,other_index2(j))*GenericTrainData(:,:,other_index2(j))';
    other_gc2 = other_gc2 + tmp./trace(tmp);    
end

omega1 = ((1-beta)*target_c1 + beta*other_c1)/((1-beta)*target_num1 + beta*other_num1);
omega2 = ((1-beta)*target_c2 + beta*other_gc2)/((1-beta)*target_num2 + beta*other_num2);

sigma1 = (1-gamma)*omega1 + gamma/target_size*trace(omega1)*I;
sigma2 = (1-gamma)*omega2 + gamma/target_size*trace(omega2)*I;

sigma = sigma1 + sigma2;

[V,D] = eig(sigma);
P = (sqrt(D^-1))*V';
sl = P*sigma1*P';
[V,D] = eig(sl);
[D,index] = sort(diag(D));  % 将对角矩阵D的对角元素升序排列
V2 = V(:,index(1:m));  % 选取出s1最小m个特征值所对应的特征向量
index = flipud(index);
V = V(:,index);  % 将V的列重新排序，第一列为s1最大特征值所对应的特征向量
V = V(:,1:m);  % 选取出s1最大m个特征值所对应的特征向量

VV=[V V2];
W=VV'*P;

SpatialFilter = W;  % number行N列