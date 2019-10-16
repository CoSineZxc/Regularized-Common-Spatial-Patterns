function [W]=fisher_score(X,Y)

X=[[0.1,0.5];[1,1];[0.3,0.5];[0.1,0.5];[1.4,1];[1.1,1.1];[0.2,0.6]];
Y=[1,2,1,1,2,2,1];

num_Class=size(unique(Y),2);
[~,num_Feature]=size(X);
W=zeros(1,num_Feature);

class_Index=cell(num_Class,1);
n_i=zeros(num_Class,1);
for j=1:num_Class
    class_Index{j}=find(Y(:)==j);
    n_i(j)=length(class_Index{j});
end

for i=1:num_Feature
    temp1=0;
    temp2=0;
    f_i=X(:,i);
    u_i=mean(f_i);
    
    for j=1:num_Class
        u_cj=mean(f_i(class_Index{j}));
        var_cj=var(f_i(class_Index{j}),1);
        temp1=temp1+n_i(j)*(u_cj-u_i)^2;
        temp2=temp2+n_i(j)*var_cj;
    end
    if temp1==0
        W(i)=0;
    else
        if temp2==0
            W(i)=100;
        else
            W(i)=temp1/temp2;
        end
    end
end
