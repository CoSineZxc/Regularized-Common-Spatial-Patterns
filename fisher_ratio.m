function [ fr ] = fisher_ratio( X1, X2 )
%FISHER_RATIO Summary of this function goes here

% X1=[-1.4552629,-1.8741664;-1.6279637,-1.3298970;-1.5291282,-1.6554964;-1.5698428,-1.4508430;-1.6554583,-1.3596447;-1.9039968,-1.8507921;-1.2291290,-1.4622483;-1.3987508,-1.7271037;-1.3820804,-1.1891441];
% X2=[-1.7000914,-1.4731126;-1.7058909,-1.6256616;-1.3092197,-1.7046062;-1.5112635,-1.5403650;-1.5150101,-1.3514910;-2.4751053,-2.6186368;-2.0074527,-1.8643204;-1.9727144,-2.3038962;-1.9836423,-2.1033154];

if size(X1,2)~=size(X2,2)
    disp('The feature demension of two clases is not the same!')
end


fr = zeros(size(X1,2),1);

for I=1:size(X1,2)
     maxvalue=max(max(X1(:,I)),max(X2(:,I)));
     maxmatrix=ones(size(X1,1),1)*maxvalue;
     X1(:,I)=X1(:,I)./maxmatrix;
     X2(:,I)=X2(:,I)./maxmatrix;
    fr(I,1)=(mean(X1(:,I))-mean(X2(:,I)))^2/ (var(X1(:,I))^2+var(X2(:,I))^2);
end

maxvalue=max(fr);
maxmatrix=ones(size(fr,1),1)*maxvalue;
fr=fr./maxmatrix;
