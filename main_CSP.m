% function acc=main_CSP(train_size,Target)

% testpath = which('main_CSP.m');
% testpath = testpath(1:end-length('main.m'));
% addpath([testpath 'PublicToolbox']);
% addpath([testpath 'PublicToolbox\eeglab\functions']);
% addpath([testpath 'PublicToolbox\libsvm-mat-2.89-1']);
% Target=[1,1,0];
% train_size=10;
clear;

Target=[0,1,1];
train_size=15;

Left_Right=Target(1);
Left_Foot=Target(2);
Right_Foot=Target(3);

featurenumberrange = [2:2:6]; 
fold = 5;
class1 = 1;
class2 = 2;
TrainSize=train_size;

TrainData = [];
TrainDataLabel = [];
TestData=[];
TestDataLabel=[];

% load('wdm_6class_old.mat','EEG');
load('zxc_6class_20190905.mat','EEG');
Label=cat(1,EEG.event.type);

index=find(strcmp(Label,"S 68"));
% index=find(strcmp(Label,"S 79"));
rand_index=randperm(size(index,1));
train_index=rand_index(1:train_size);
test_index=rand_index(train_size+1:end);

if Left_Right==1
    index=find(strcmp(Label,"S 68"));
    % index=find(strcmp(Label,"S 79"));
    EEGdata=EEG.data(1:62,501:end,index);
    TrainData=cat(3,TrainData,EEGdata(:,:,train_index));
    TestData=cat(3,TestData,EEGdata(:,:,test_index));
    TrainDataLabel=cat(1,TrainDataLabel,class1*ones(TrainSize, 1));
    TestDataLabel=cat(1,TestDataLabel,class1*ones(size(EEGdata, 3)-TrainSize, 1));
end
if Left_Foot==1
    index=find(strcmp(Label,"S 85"));
    % index=find(strcmp(Label,"S 95"));
    EEGdata=EEG.data(1:62,501:end,index);
    TrainData=cat(3,TrainData,EEGdata(:,:,train_index));
    TestData=cat(3,TestData,EEGdata(:,:,test_index));
    if Left_Right==1
        TrainDataLabel=cat(1,TrainDataLabel,class2*ones(TrainSize, 1));
        TestDataLabel=cat(1,TestDataLabel,class2*ones(size(EEGdata, 3)-TrainSize, 1));
    else
        TrainDataLabel=cat(1,TrainDataLabel,class1*ones(TrainSize, 1));
        TestDataLabel=cat(1,TestDataLabel,class1*ones(size(EEGdata, 3)-TrainSize, 1));
    end
end
if Right_Foot==1
    index=find(strcmp(Label,"S102"));
    % index=find(strcmp(Label,"S111"));
    EEGdata=EEG.data(1:62,501:end,index);
    TrainData=cat(3,TrainData,EEGdata(:,:,train_index));
    TestData=cat(3,TestData,EEGdata(:,:,test_index));
    TrainDataLabel=cat(1,TrainDataLabel,class2*ones(TrainSize, 1));
    TestDataLabel=cat(1,TestDataLabel,class2*ones(size(EEGdata, 3)-TrainSize, 1));
end

%%%------Get discriminative spatial pattern in trainning data
maxtrainaccuracy = 0;
for featurenum = featurenumberrange
    [SpatialFilter,A] = feature_CSP(TrainData, TrainDataLabel, featurenum);
    
    %%%------get class features
    trainfeature = [];
    for j = 1:size(TrainData,3)
        temp = SpatialFilter*squeeze(TrainData(:,:,j));
        feature = var(temp,0,2);
        feature = feature./sum(feature);
        feature = log(feature);
        trainfeature = [trainfeature; feature'];
    end
    
    %%%------Get SVM model in trainning data
    classifiermodel = trainSVMrbfclassifier(double(trainfeature),TrainDataLabel,fold);
    
    if classifiermodel.trainaccuracy > maxtrainaccuracy
        maxtrainaccuracy = classifiermodel.trainaccuracy;
        lastfeaturenum = featurenum;
        lastfeature = trainfeature;
        lastSpatialFilter = SpatialFilter;
        lastclassifiermodel = classifiermodel;
    end
end

%test

testfeature = [];
for j = 1:size(TestData,3)
    temp = lastSpatialFilter*squeeze(TestData(:,:,j));
    feature = var(temp,0,2);
    feature = feature./sum(feature);
    feature = log(feature);
    testfeature = [testfeature; feature'];
end

[testdata] = scaleproj(double(testfeature), lastclassifiermodel.MinV,lastclassifiermodel.MaxV);
[predict_label, accuracy, prob_estimates] = svmpredict(TestDataLabel, testdata, lastclassifiermodel.model); 
acc=accuracy(1);