% function [acc,lastbeta,lastgamma]=main_RCSP(train_size, select_size,Other,Target)

% testpath = which('main_RCSP.m');
% testpath = testpath(1:end-length('main_RCSP.m'));
% addpath([testpath 'PublicToolbox']);
% addpath([testpath 'PublicToolbox\eeglab\functions']);
% addpath([testpath 'PublicToolbox\libsvm-mat-2.89-1']);

Other=[1,1,0];
Target=[1,0,1];
train_size=10;
select_size=5;

Other_left=Other(1);
Other_right=Other(2);
Other_foot=Other(3);
target_LF=Target(1);
target_RF=Target(2);
target_LR=Target(3);

class1=1;
class2=2;
OtherEEGData=[];
OtherLabel=[];
TargetSize=train_size;
TargetSelectSize=select_size;
TargetEEGData_train=[];
TargetLabel_train=[];
TargetEEGData_Select=[];
TargetLabel_Select=[];
TargetEEGData_test=[];
TargetLabel_test=[];

load('wdm_6class_20190907.mat','EEG');
Label=cat(1,EEG.event.type);
% left-17 right-34 foot-51 left&right-68 left&foot-85 right&foot-102

if Other_left==1
    index=find(strcmp(Label,"S 17"));
    % index=find(strcmp(Label,"S 31"));
    EEGdata=EEG.data(1:62,501:end,index);
    OtherEEGData=cat(3,OtherEEGData,EEGdata);
    OtherLabel=cat(1,OtherLabel,class1*ones(size(EEGdata, 3), 1));
end
if Other_right==1
    index=find(strcmp(Label,"S 34"));
    % index=find(strcmp(Label,"S 47"));
    EEGdata=EEG.data(1:62,501:end,index);
    OtherEEGData=cat(3,OtherEEGData,EEGdata);
    if Other_left==1
        OtherLabel=cat(1,OtherLabel,class2*ones(size(EEGdata, 3), 1));
    else
        OtherLabel=cat(1,OtherLabel,class1*ones(size(EEGdata, 3), 1));
    end
end
if Other_foot==1
    index=find(strcmp(Label,"S 51"));
    % index=find(strcmp(Label,"S 63"));
    EEGdata=EEG.data(1:62,501:end,index);
    OtherEEGData=cat(3,OtherEEGData,EEGdata);
    OtherLabel=cat(1,OtherLabel,class2*ones(size(EEGdata, 3), 1));
end

rand_index=randperm(size(EEGdata,3));
train_index=rand_index(1:train_size);
select_index=rand_index(train_size+1:train_size+select_size);
test_index=rand_index(train_size+select_size+1:end);


if target_LR==1
    index=find(strcmp(Label,"S 68"));
    % index=find(strcmp(Label,"S 79"));
    EEGdata=EEG.data(1:62,501:end,index);
    TargetEEGData_train=cat(3,TargetEEGData_train,EEGdata(:,:,train_index));
    TargetEEGData_Select=cat(3,TargetEEGData_Select,EEGdata(:,:,select_index));
    TargetEEGData_test=cat(3,TargetEEGData_test,EEGdata(:,:,test_index));
    TargetLabel_train=cat(1,TargetLabel_train,class1*ones(TargetSize, 1));
    TargetLabel_Select=cat(1,TargetLabel_Select,class1*ones(TargetSelectSize, 1));
    TargetLabel_test=cat(1,TargetLabel_test,class1*ones(size(EEGdata, 3)-TargetSize-TargetSelectSize, 1));
end
if target_LF==1
    index=find(strcmp(Label,"S 85"));
    % index=find(strcmp(Label,"S 95"));
    EEGdata=EEG.data(1:62,501:end,index);
    TargetEEGData_train=cat(3,TargetEEGData_train,EEGdata(:,:,train_index));
    TargetEEGData_Select=cat(3,TargetEEGData_Select,EEGdata(:,:,select_index));
    TargetEEGData_test=cat(3,TargetEEGData_test,EEGdata(:,:,test_index));
    if target_LR==1
        TargetLabel_train=cat(1,TargetLabel_train,class2*ones(TargetSize, 1));
        TargetLabel_Select=cat(1,TargetLabel_Select,class2*ones(TargetSelectSize, 1));
        TargetLabel_test=cat(1,TargetLabel_test,class2*ones(size(EEGdata, 3)-TargetSize-TargetSelectSize, 1));
    else
        TargetLabel_train=cat(1,TargetLabel_train,class1*ones(TargetSize, 1));
        TargetLabel_Select=cat(1,TargetLabel_Select,class1*ones(TargetSelectSize, 1));
        TargetLabel_test=cat(1,TargetLabel_test,class1*ones(size(EEGdata, 3)-TargetSize-TargetSelectSize, 1));
    end
end
if target_RF==1
    index=find(strcmp(Label,"S102"));
    % index=find(strcmp(Label,"S111"));
    EEGdata=EEG.data(1:62,501:end,index);
    TargetEEGData_train=cat(3,TargetEEGData_train,EEGdata(:,:,train_index));
    TargetEEGData_Select=cat(3,TargetEEGData_Select,EEGdata(:,:,select_index));
    TargetEEGData_test=cat(3,TargetEEGData_test,EEGdata(:,:,test_index));
    TargetLabel_train=cat(1,TargetLabel_train,class2*ones(TargetSize, 1));
    TargetLabel_Select=cat(1,TargetLabel_Select,class2*ones(TargetSelectSize, 1));
    TargetLabel_test=cat(1,TargetLabel_test,class2*ones(size(EEGdata, 3)-TargetSize-TargetSelectSize, 1));
end

featurenumberrange = (2:2:6); 
fold = 5;

maxtestaccuracy = 0;
lastbeta = 0;
lastgamma = 0;
bestSpatialFilter=0;
bestclassifiermodel=0;
results = [];
valid_acc_set=[];
test_acc_set=[];
beta_range=(0.05:0.05:0.95);
gamma_range=(0.05:0.05:0.95);

for beta = beta_range
    valid_acc_line=[];
    test_acc_line=[];
    for gamma = gamma_range
        maxtrainaccuracy = 0;
        for featurenum = featurenumberrange
            [SpatialFilter] = feature_RCSP(TargetEEGData_train, TargetLabel_train, OtherEEGData, OtherLabel, featurenum, beta, gamma);

            %%%------get class features
            trainfeature = [];
            for j = 1:size(TargetEEGData_train,3)
                temp = SpatialFilter*squeeze(TargetEEGData_train(:,:,j));
                feature = var(temp,0,2);
                feature = feature./sum(feature);
                feature = log(feature);
                trainfeature = [trainfeature; feature'];
            end

            %%%------Get SVM model in trainning data
            classifiermodel = trainSVMrbfclassifier(double(trainfeature), TargetLabel_train,fold);

            if classifiermodel.trainaccuracy > maxtrainaccuracy
                maxtrainaccuracy = classifiermodel.trainaccuracy;
                lastfeaturenum = featurenum;
                lastfeature = trainfeature;
                lastSpatialFilter = SpatialFilter;
                lastclassifiermodel = classifiermodel;
            end
        end

        Selectfeature = [];
        for j = 1:size(TargetEEGData_Select,3)
            temp = lastSpatialFilter*squeeze(TargetEEGData_Select(:,:,j));
            feature = var(temp,0,2);
            feature = feature./sum(feature);
            feature = log(feature);
            Selectfeature = [Selectfeature; feature'];
        end

        [testdata] = scaleproj(double(Selectfeature), lastclassifiermodel.MinV,lastclassifiermodel.MaxV);
        [predicted_label, accuracy, prob_estimates] = svmpredict(TargetLabel_Select, testdata, lastclassifiermodel.model); 
        valid_acc_line=cat(1,valid_acc_line,accuracy(1));
        
        if accuracy(1) >= maxtestaccuracy
            maxtestaccuracy = accuracy(1);
            lastbeta = beta;
            lastgamma = gamma;
            bestSpatialFilter=lastSpatialFilter;
            bestclassifiermodel=lastclassifiermodel;
        end
        result = [beta gamma accuracy(1)];
        results = [results; result];
        
        Testfeature = [];
        for j = 1:size(TargetEEGData_test,3)
            temp = lastSpatialFilter*squeeze(TargetEEGData_test(:,:,j));
            feature = var(temp,0,2);
            feature = feature./sum(feature);
            feature = log(feature);
            Testfeature = [Testfeature; feature'];
        end
        [testdata] = scaleproj(double(Testfeature), lastclassifiermodel.MinV,lastclassifiermodel.MaxV);
        [predicted_label, accuracy, prob_estimates] = svmpredict(TargetLabel_test, testdata, lastclassifiermodel.model);
        test_acc_line=cat(1,test_acc_line,accuracy(1));
    end
    valid_acc_set=cat(2,valid_acc_set,valid_acc_line);
    test_acc_set=cat(2,test_acc_set,test_acc_line);
end

[X,Y]=meshgrid(beta_range,gamma_range);
Z1=griddata(beta_range,gamma_range,valid_acc_set,X,Y,'v4');
Z2=griddata(beta_range,gamma_range,test_acc_set,X,Y,'v4');
figure(1);
subplot(2,1,1);
surf(X,Y,Z1);
xlabel('beta');
ylabel('gamma');
zlabel('valid acc');
subplot(2,1,2);
surf(X,Y,Z2);
xlabel('beta');
ylabel('gamma');
zlabel('test acc');

fprintf('best beta is %d, gamma is %d\n', lastbeta, lastgamma); 
Testfeature = [];
for j = 1:size(TargetEEGData_test,3)
    temp = bestSpatialFilter*squeeze(TargetEEGData_test(:,:,j));
    feature = var(temp,0,2);
    feature = feature./sum(feature);
    feature = log(feature);
    Testfeature = [Testfeature; feature'];
end
[testdata] = scaleproj(double(Testfeature), bestclassifiermodel.MinV,bestclassifiermodel.MaxV);
[predicted_label, accuracy, prob_estimates] = svmpredict(TargetLabel_test, testdata, bestclassifiermodel.model);

fprintf('Max test accuracy is %d\n',accuracy(1)); 
acc=accuracy(1);
