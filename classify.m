function  [testaccuracy]=classify(data1,data2,cvalue,gvalue,fold);
testnum=size(data1,1);
testdata=[data1;data2];
[testdata]=scale(testdata);

testlabel=[ones(1,testnum) ones(1,testnum)*2]';
strc=num2str(cvalue);
strg=num2str(gvalue);
fold=num2str(fold);
sss=['-c ' strc  ' -g ' strg ' -v ' fold];      
testaccuracy= svmtrain(testlabel,testdata,sss);
fprintf('Testing data Crossaccuracy=%d   \n',testaccuracy);
end

