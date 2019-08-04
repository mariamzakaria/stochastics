close all
clc, clear
%% Load EEG Dataset
% this is a motor imagery dataset. We have two classes.
% Class 1 where subject imagines moving his right arm.
% Class 2 where subject imagines moving his left arm.
% There is different EEG channels C3, C4 and Cz 
% We will select only one of them. 
load('pre.mat')
class1=num;
load('event.mat')
class2=num;
load('post.mat')
test=num;

for ch=1:size(num,2)
    % Note : detrend -> makes the signal zero mean 
    dataClass1 = detrend(class1(:,ch),0);
    %first Channel from class 2 
    dataClass2 = detrend(class2(:,ch),0);
    data = [dataClass1, dataClass2];
    %Test data
    testData = detrend(test(:,ch),0);

    % Empty cell array to be updated with selected models for both class 1 and 2
    selectedModels = cell(2,1);
    %% [1] Models Estimation  
    % MA(2), AR(2), ARMA(1,2) Models
    % We have two classes so we will estimate models and select one for each class.
    for i = 1:2
        [model_MA2, ~, logL_MA2] = estimate(arima(0,0,2),data(:,i));
        [model_AR2, ~, logL_AR2] = estimate(arima(2,0,0),data(:,i));
        [model_ARMA12, ~, logL_ARMA12] = estimate(arima(1,0,2),data(:,i));
        models = {model_MA2, model_AR2, model_ARMA12};

        %% [2] Model Selection based on AIC value
        %Calculte Akiak's information criteria for all models
        aic_MA2 = 2*2 - 2*logL_MA2;
        aic_AR2 = 2*2 - 2*logL_AR2;
        aic_ARMA12 = 2*3 - 2*logL_ARMA12;

        % Select model with minimum aic
        [~, idx] = min([aic_MA2, aic_AR2, aic_ARMA12])
        % Update selected models
        selectedModels{i} = models{idx};
    end

    % Initialize an array to be updated with likelihood values for each class
    likelihoodVals = zeros(1,2);
    %% [3] Hypothesis test 
    for i = 1:2
    % Calculate likelihood estimate for testData using selected model of each
    % class 
        [~,~,logL] = estimate(selectedModels{i},testData);
        likelihoodVals(i) = logL;
    end
    %Select class with maximum likelihood value
    [~, testDataClass(ch)] = max(likelihoodVals);
    display(['Channel  ',num2str(ch)]);
    display(['testDataClass: ',num2str(testDataClass(ch))])
end




