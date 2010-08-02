classdef prtDataSetFile < prtDataSetBase
    
    properties
        fileList
        readOnly
        
        loadFn
        writeFn
        
        ObservationDependentUserData
    end
    
    properties (Dependent)
        nObservations         % Abstract, implement as size(data,1)
        nFeatures             % Abstract, implement as size(data,2)
        nTargetDimensions     % Abstract, implement as size(targets,2)
    end
    
    properties (Hidden)
        internalStandardDataSet
    end
    
    methods
        function fileList = getFiles(obj,indices)
            fileList = obj.fileList(indices);
        end
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.fileList,1);
        end
        function nFeatures = get.nFeatures(obj)
            nFeatures = nan;
        end
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = obj.internalStandardDataSet.nTargetDimensions;
        end
        
        
        
        function data = getObservations(obj,indices1)
            if nargin < 2 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                data(i,:) = obj.loadFn(obj.fileList{indices1(i)});
            end
        end
        
        function targets = getTargets(obj,varargin)
            targets = obj.internalStandardDataSet.getTargets(varargin{:});
        end
        
        function [data,targets] = getObservationsAndTargets(obj,varargin)
            data = getObservations(obj,varargin{:});
            targets = getTargets(obj,varargin{:});
        end
        
        function obj = setObservations(obj,data,indices1)
            if obj.readOnly
                error('Attempt to set observations for a read-only prtDataSetFile; this will attempt to overwrite existing files.');
            end
            if nargin < 3 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                obj.writeFn(obj.fileList{i},data(i,:));
            end
        end
        
        function obj = setTargets(obj,varargin)
            obj.internalStandardDataSet = obj.internalStandardDataSet.setTargets(varargin{:});
        end
            
        function obj = setObservationsAndTargets(obj,data,targets)
            if obj.readOnly
                error('Attempt to set observations for a read-only prtDataSetFile; this will attempt to overwrite existing files.');
            end
            if nargin < 3 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                obj.writeFn(obj.fileList{i},data(i,:));
            end
            obj.internalStandardDataSet = obj.internalStandardDataSet.setTargets(targets);
        end
        
        function [obj,retainedIndices] = removeObservations(obj,removeIndices)
            prtDataSetStandard.checkIndices(removeIndices,obj.nObservations);
            
            if islogical(removeIndices)
                keepObservations = ~removeIndices;
            else
                keepObservations = setdiff(1:obj.nObservations,removeIndices);
            end
            [obj,retainedIndices] = retainObservations(obj,keepObservations);
        end
        
        function obj = removeTargets(obj,indices)
            obj.internalStandardDataSet = obj.internalStandardDataSet.removeTargets(obj,indices);
        end
        
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            %[obj,retainedIndices] = retainObservations(obj,retainedIndices)
            warning('prt:Fixable','Does not handle observation names');
            prtDataSetStandard.checkIndices(retainedIndices,obj.nObservations);
            
            obj.fileList = obj.fileList(retainedIndices);
            if obj.isLabeled
                obj.targets = obj.targets(retainedIndices,:);
            end
            
            if ~isempty(obj.ObservationDependentUserData)
                obj.ObservationDependentUserData = obj.ObservationDependentUserData(retainedIndices);
            end
        end
        
        function obj = retainTargets(obj,indices)
            obj.internalStandardDataSet = obj.internalStandardDataSet.removeTargets(obj,indices);
        end
        
        function obj = catObservations(obj,varargin)
            error('not implemented');
        end
        function obj = catTargets(obj,dataSet)
            error('not implemented');
        end
        
        function handles = plot(obj)
            error('not implemented');
        end
        function export(obj,prtExportObject)
            error('not implemented');
        end
        function Summary = summarize(obj)
            error('not implemented');
        end
    end
    
end