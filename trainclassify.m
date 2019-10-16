function  [accuracy,model,MaxV,MinV]=trainclassify(traindata1,traindata2,fold)

trainnum1=size(traindata1,1);
trainnum2=size(traindata2,1);
traindata=[traindata1;traindata2];
[traindata,MaxV,MinV] = scale(traindata);
trainlabel=[ones(1,trainnum1) ones(1,trainnum2)*2]';

accuracy=0;

for i=1:10
    for j=1:10
            tempstrc=num2str(double(2^i));
            tempstrg=num2str(double(2^(-j)));
            fold=num2str(fold);
            sss=['-c ' tempstrc  ' -g ' tempstrg ' -v ' fold];     

            tempaccuracy= svmtrain(trainlabel,traindata,sss);
        
            if tempaccuracy>accuracy
                accuracy=tempaccuracy;
                strc=tempstrc;
                strg=tempstrg;
                ss=['-c ' strc  ' -g ' strg];     
                model = svmtrain(trainlabel,traindata,ss);
            end
    end
end
   

fprintf('Max training data Crossaccuracy is %d \n',accuracy); 

end 
