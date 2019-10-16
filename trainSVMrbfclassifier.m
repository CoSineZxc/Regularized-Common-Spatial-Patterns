function  [classifiermodel]=trainSVMrbfclassifier(traindata,trainlabel,fold);
 classifiermodel= struct;  
 [traindata,classifiermodel.MaxV,classifiermodel.MinV] = scale(traindata);

classifiermodel.trainaccuracy=0;

for i=1:10
    for j=1:10
            tempstrc=num2str(double(2^i));
            tempstrg=num2str(double(2^(-j)));
            fold=num2str(fold);
            sss=['-c ' tempstrc  ' -g ' tempstrg ' -v ' fold ];     

            tempaccuracy= svmtrain(trainlabel,traindata,sss);
        
            if tempaccuracy>classifiermodel.trainaccuracy
            classifiermodel.trainaccuracy=tempaccuracy;
            strc=tempstrc;
            strg=tempstrg;

            end
    end
 
end

            ss=['-c ' strc  ' -g ' strg ' -b 1'];
            classifiermodel.model = svmtrain(trainlabel,traindata,ss);

fprintf('Max training data Crossaccuracy is %d \n',classifiermodel.trainaccuracy); 

end 

% libsvmstring = ' -s 0 -t 0  ';
%  string=[ ' -s 0 -t 0  ',' -c 2',' -b 1'];
% classifiermodel.model = svmtrain(trainlabel,traindata, string);