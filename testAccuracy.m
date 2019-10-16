function [accuracy] = testAccuracy(TestData, TestDataLabel, SpatialFilter, classifiermodel)

testfeature = [];
for j = 1:size(TestData,3)
    temp = SpatialFilter*squeeze(TestData(:,:,j));
    feature = var(temp,0,2);
    feature = feature./sum(feature);
    feature = log(feature);
    testfeature = [testfeature; feature'];
end

[testdata] = scaleproj(testfeature, classifiermodel.MinV,classifiermodel.MaxV);
[predict_label, p, temp] = svmpredict(TestDataLabel, testdata, classifiermodel.model); 
accuracy = p(1);