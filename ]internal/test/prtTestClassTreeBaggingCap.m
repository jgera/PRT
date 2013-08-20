function result = prtTestClassTreeBaggingCap

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
result = true;


% BASELINE generation, uncomment to run to generate new baseline
% Run numIter times to get idea distribution of percentage
% Pick off the lowest % correct and use that as baseline
% numIter = 100;
% percentCorr = zeros(1,numIter);
% for i = 1:numIter
%     TestDataSet = prtDataGenUnimodal;
%     TrainingDataSet = prtDataGenUnimodal;
% 
%     classifier = prtClassTreeBaggingCap;
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     classes  = classified.getX > .5;
%     percentCorr(i) = prtScorePercentCorrect(classes,TestDataSet.getTargets);
% end
% min(percentCorr)


%% Classification correctness test.
baselinePercentCorr =  0.9325;

TestDataSet = prtDataGenUnimodal;
TrainingDataSet = prtDataGenUnimodal;
%TrainingDataSet = .catFeatures(prtDataGenUnimodal,prtDataGenUnimodal);

nTrees = 100;

classifier = prtClassTreeBaggingCap('nTrees',nTrees); % 
%classifier.verboseStorage = false;
classifier = classifier.train(TrainingDataSet);
classified = run(classifier, TestDataSet);

classes  = classified.getX > .5;

percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

% make sure plotting succeeds
try
    classifier.plot();
    close;
catch
    result = false;
    disp('TreeBaggingCap class plot fail')
    close
end


%% Check that cross-val and k-folds work

TestDataSet = prtDataGenUnimodal;
classifier = prtClassTreeBaggingCap('nTrees',nTrees);

% cross-val
keys = mod(1:400,2);
crossVal = classifier.crossValidate(TestDataSet,keys);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

% k-folds

crossVal = classifier.kfolds(TestDataSet,10);
classes  = crossVal.getX > .5;
percentCorr = prtScorePercentCorrect(classes,TestDataSet.getTargets);

result = result & (percentCorr > baselinePercentCorr);

% check that i can change cap classifier
% try
%     CAP = prtClassCap;
%     classifier.CapClassifier = {CAP};
%     classifier = classifier.train(TrainingDataSet);
%     classified = run(classifier, TestDataSet);
%     
% catch
%     result = false;
%     disp('error changing classifier TreeBaggingCap classifier')
% end
% 


%check that i can turn off bootstrapping
try
    % classifier.bootStrapDataAtNodes = false;
    classifier.bootStrapDataAtRoots = false;
    
    classifier = classifier.train(TestDataSet);
    classified = run(classifier, TestDataSet);
    
catch
    disp('TreeBaggingCap boostrapping fail')
    result = false;
end


%% Object construction
% We want these to be non-errors
noerror = true;

try
    classifier = prtClassTreeBaggingCap('nTrees', 40);
catch
    noerror = false;
end
% %%
result = result & noerror;