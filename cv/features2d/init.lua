local cv = require 'cv._env'

local ffi = require 'ffi'

local C = ffi.load(cv.libPath('features2d'))

--- ***************** Classes *****************

require 'cv.Classes'

local Classes = ffi.load(cv.libPath('Classes'))

ffi.cdef[[
struct KeyPointWrapper {
    struct Point2fWrapper pt;
    float size, angle, response;
    int octave, class_id;
};

struct KeyPointArray {
    struct KeyPointWrapper *data;
    int size;
};

struct KeyPointMat {
    struct KeyPointWrapper **data;
    int size1, size2;
};

struct PtrWrapper KeyPointsFilter_ctor();

void KeyPointsFilter_dtor(struct PtrWrapper ptr);

struct KeyPointArray KeyPointsFilter_runByImageBorder(struct KeyPointArray keypoints,
                        struct SizeWrapper imageSize, int borderSize);

struct KeyPointArray KeyPointsFilter_runByKeypointSize(struct KeyPointArray keypoints, float minSize,
                        float maxSize);

struct KeyPointArray KeyPointsFilter_runByPixelsMask(struct KeyPointArray keypoints,
                        struct TensorWrapper mask);

struct KeyPointArray KeyPointsFilter_removeDuplicated(struct KeyPointArray keypoints);

struct KeyPointArray KeyPointsFilter_retainBest(struct KeyPointArray keypoints, int npoints);

struct PtrWrapper Feature2D_ctor();

struct KeyPointArray Feature2D_detect(struct PtrWrapper ptr, struct TensorWrapper image, struct KeyPointArray keypoints,
                        struct TensorWrapper mask);

struct KeyPointMat Feature2D_detect2(struct PtrWrapper ptr, struct TensorArray images,
                        struct KeyPointMat keypoints, struct TensorArray masks);

struct KeyPointArray Feature2D_compute(struct PtrWrapper ptr, struct TensorWrapper image,
                        struct KeyPointArray keypoints, struct TensorWrapper descriptors);

struct KeyPointMat Feature2D_compute2(struct PtrWrapper ptr, struct TensorArray images,
                        struct KeyPointMat keypoints, struct TensorArray descriptors);

struct KeyPointArray Feature2D_detectAndCompute(struct PtrWrapper ptr, struct TensorWrapper image,
                        struct TensorWrapper mask, struct KeyPointArray keypoints,
                        struct TensorWrapper descriptors, bool useProvidedKeypoints);

int Feature2D_descriptorSize(struct PtrWrapper ptr);

int Feature2D_descriptorType(struct PtrWrapper ptr);

int Feature2D_defaultNorm(struct PtrWrapper ptr);

bool Feature2D_empty(struct PtrWrapper ptr);

struct PtrWrapper BRISK_ctor(int thresh, int octaves, float patternScale);

struct PtrWrapper BRISK_ctor2(struct TensorWrapper radiusList, struct TensorWrapper numberList,
                        float dMax, float dMin, struct TensorWrapper indexChange);

struct PtrWrapper ORB_ctor(int nfeatures, float scaleFactor, int nlevels, int edgeThreshold, int firstLevel,
                        int WTA_K, int scoreType, int patchSize, int fastThreshold);

void ORB_setMaxFeatures(struct PtrWrapper ptr, int maxFeatures);

int ORB_getMaxFeatures(struct PtrWrapper ptr);

void ORB_setScaleFactor(struct PtrWrapper ptr, int scaleFactor);

int ORB_getScaleFactor(struct PtrWrapper ptr);

void ORB_setNLevels(struct PtrWrapper ptr, int nlevels);

int ORB_getNLevels(struct PtrWrapper ptr);

void ORB_setEdgeThreshold(struct PtrWrapper ptr, int edgeThreshold);

int ORB_getEdgeThreshold(struct PtrWrapper ptr);

void ORB_setFirstLevel(struct PtrWrapper ptr, int firstLevel);

int ORB_getFirstLevel(struct PtrWrapper ptr);

void ORB_setWTA_K(struct PtrWrapper ptr, int wta_k);

int ORB_getWTA_K(struct PtrWrapper ptr);

void ORB_setScoreType(struct PtrWrapper ptr, int scoreType);

int ORB_getScoreType(struct PtrWrapper ptr);

void ORB_setPatchSize(struct PtrWrapper ptr, int patchSize);

int ORB_getPatchSize(struct PtrWrapper ptr);

void ORB_setFastThreshold(struct PtrWrapper ptr, int fastThreshold);

int ORB_getFastThreshold(struct PtrWrapper ptr);

struct PtrWrapper MSER_ctor(int _delta, int _min_area, int _max_area, double _max_variation, double _min_diversity,
                        int _max_evolution, double _area_threshold, double _min_margin, int _edge_blur_size);

void MSER_setDelta(struct PtrWrapper ptr, int delta);

int MSER_getDelta(struct PtrWrapper ptr);

void MSER_setMinArea(struct PtrWrapper ptr, int minArea);

int MSER_getMinArea(struct PtrWrapper ptr);

void MSER_setMaxArea(struct PtrWrapper ptr, int MaxArea);

int MSER_getMaxArea(struct PtrWrapper ptr);




struct KeyPointArray AGAST(
        struct TensorWrapper image, int threshold, bool nonmaxSuppression);
]]

function cv.KeyPoint(...)
    return ffi.new('struct KeyPointWrapper', ...)
end

-- KeyPointsFilter

do
    local KeyPointsFilter = cv.newTorchClass('cv.KeyPointsFilter')

    function KeyPointsFilter:__init()
        self.ptr = ffi.gc(C.KeyPointsFilter_ctor(), C.KeyPointsFilter_dtor)
    end

    function KeyPointsFilter:runByImageBorder(t)
        local argRules = {
            {"keypoints", required = true},
            {"imageSize", required = true, operator = cv.Size},
            {"borderSize", required = true}
        }
        local keypoints, imageSize, borderSize = cv.argcheck(t, argRules)
        
        return C.KeyPointsFilter_runByImageBorder(keypoints, imageSize, borderSize);
    end

    function KeyPointsFilter:runByKeypointSize(t)
        local argRules = {
            {"keypoints", required = true},
            {"minSize", required = true},
            {"maxSize", default = FLT_MAX}
        }
        local keypoints, minSize, maxSize = cv.argcheck(t, argRules)

        return C.KeyPointsFilter_runByKeypointSize(keypoints, imageSize, borderSize);
    end

    function KeyPointsFilter:runByPixelsMask(t)
        local argRules = {
            {"keypoints", required = true},
            {"mask", required = true}
        }
        local keypoints, mask = cv.argcheck(t, argRules)

        return C.KeyPointsFilter_runByPixelsMask(keypoints, cv.wrap_tensor(mask))
    end

    function KeyPointsFilter:removeDuplicated(t)
        local argRules = {
            {"keypoints", required = true}
        }
        local keypoints = cv.argcheck(t, argRules)

        return C.KeyPointsFilter_removeDuplicated(keypoints)
    end

    function KeyPointsFilter:retainBest(t)
        local argRules = {
            {"keypoints", required = true},
            {"npoints", required = true}
        }
        local keypoints, npoints = cv.argcheck(t, argRules)

        return C.KeyPointsFilter_retainBest(keypoints, npoints)
    end
end

-- Feature2D

do
    local Feature2D = cv.newTorchClass('cv.Feature2D', 'cv.Algorithm')

    function Feature2D:__init()
        self.ptr = ffi.gc(C.Feature2D_ctor(), Classes.Algorithm_dtor)
    end

    function Feature2D:detect(t)
        local argRules = {
            {"image", required = true},
            {"keypoints", required = true},
            {"mask", default = nil}
        }
        local image, keypoints, mask = cv.argcheck(t, argRules)

        return C.Feature2D_detect(self.ptr, cv.wrap_tensor(image), keypoints, cv.wrap_tensor(mask))
    end

    function Feature2D:detect2(t)
        local argRules = {
            {"images", required = true},
            {"keypoints", required = true},
            {"masks", default = nil}
        }
        local images, keypoints, masks = cv.argcheck(t, argRules)

        return C.Feature2D_detect2(self.ptr, cv.wrap_tensors(images), keypoints, cv.wrap_tensors(masks))
    end

    function Feature2D:compute(t)
        local argRules = {
            {"image", required = true},
            {"keypoints", required = true},
            {"descriptors", required = true}
        }
        local image, keypoints, descriptors = cv.argcheck(t, argRules)

        return C.Feature2D_compute(self.ptr, cv.wrap_tensor(image), keypoints, cv.wrap_tensor(descriptors))
    end

    function Feature2D:compute2(t)
        local argRules = {
            {"images", required = true},
            {"keypoints", required = true},
            {"descriptors", required = true}
        }
        local images, keypoints, descriptors = cv.argcheck(t, argRules)

        return C.Feature2D_compute(self.ptr, cv.wrap_tensors(images), keypoints, cv.wrap_tensors(descriptors))
    end

    function Feature2D:detectAndCompute(t)
        local argRules = {
            {"image", required = true},
            {"mask", required = true},
            {"keypoints", required = true},
            {"descriptors", required = true},
            {"useProvidedKeypoints", default = false}
        }
        local image, mask, keypoints, descriptors, useProvidedKeypoints = cv.argcheck(t, argRules)

        return C.Feature2D_detectAndCompute(self.ptr, cv.wrap_tensors(image), cv.wrap_tensors(mask),
                    keypoints, cv.wrap_tensors(descriptors), useProvidedKeypoints)
    end

    function Feature2D:descriptorSize()
        return C.Feature2D_descriptorSize(self.ptr)
    end

    function Feature2D:descriptorType()
        return C.Feature2D_descriptorType(self.ptr)
    end

    function Feature2D:defaultNorm()
        return C.Feature2D_defaultNorm(self.ptr)
    end

    function Feature2D:empty()
        return C.Feature2D_empty(self.ptr)
    end
end

-- BRISK

do
    local BRISK = cv.newTorchClass('cv.BRISK', 'cv.Feature2D')

    function BRISK:__init(t)
        if t.radiusList or type(t[1]) ~= "number" then
            local argRules = {
                {"radiusList", required = true},
                {"numberList", required = true},
                {"dMax", default = 5.85},
                {"dMin", default = 8.2},
                {"indexChange", default = nil}
            }
            local radiusList, numberList, dMax, dMin, indexChange = cv.argcheck(t, argRules)

            if type(radiusList) == "table" then
                radiusList = torch.FloatTensor(radiusList)
            end

            if type(numberList) == "table" then
                numberList = torch.IntTensor(numberList)
            end

            if type(indexChange) == "table" then
                indexChange = torch.IntTensor(indexChange)
            end

            self.ptr =  ffi.gc(C.BRISK_ctor2(cv.wrap_tensor(radiusList), cv.wrap_tensor(numberList),
                                    dMax, dMin, cv.wrap_tensor(indexChange)), Classes.Algorithm_dtor)
        else
            local argRules = {
                {"thresh", default = 30},
                {"octaves", default = 3},
                {"patternScale", default = 1.0}
            }
            local thresh, octaves, patternScale = cv.argcheck(t, argRules)

            self.ptr =  ffi.gc(C.BRISK_ctor(thresh, octaves, patternScale), Classes.Algorithm_dtor)
        end
    end


end

-- ORB

do
    local ORB = cv.newTorchClass('cv.ORB', 'cv.Feature2D')

    function ORB:__init(t)
        local argRules = {
            {"nfeatures", default = 500},
            {"scaleFactor", default = 1.2},
            {"nlevels", default = 8},
            {"edgeThreshold", default = 31},
            {"firstLevel", default = 0},
            {"WTA_K", default = 2},
            {"scoreType", default = 0},
            {"patchSize", default = 31},
            {"fastThreshold", default = 20}   
        }
        local nfeatures, scaleFactor, nlevels, edgeThreshold, firstLevel, WTA_K, scoreType, patchSize, fastThreshold = cv.argcheck(t, argRules)

        self.ptr = ffi.gc(C.ORB_ctor(nfeatures, scaleFactor, nlevels, edgeThreshold,
                                firstLevel, WTA_K, scoreType, patchSize, fastThreshold),
                                Classes.Algorithm_dtor)    
    end

    function ORB:setMaxFeatures(t)
        local argRules = {
            {"maxFeatures", required = true}
        }
        local maxFeatures = cv.argcheck(t, argRules)

        C.ORB_setMaxFeatures(self.ptr, maxFeatures)
    end

    function ORB:getMaxFeatures()
        return C.ORB_getMaxFeatures(self.ptr)
    end

    function ORB:setScaleFactor(t)
        local argRules = {
            {"scaleFactor", required = true}
        }
        local scaleFactor = cv.argcheck(t, argRules)

        C.ORB_setScaleFactor(self.ptr, scaleFactor)
    end

    function ORB:getScaleFactor()
        return C.ORB_getScaleFactor(self.ptr)
    end

    function ORB:setNLevels(t)
        local argRules = {
            {"nlevels", required = true}
        }
        local nlevels = cv.argcheck(t, argRules)

        C.ORB_setNLevels(self.ptr, nlevels)
    end

    function ORB:getNLevels()
        return C.ORB_getNLevels(self.ptr)
    end

    function ORB:setEdgeThreshold(t)
        local argRules = {
            {"edgeThreshold", required = true}
        }
        local edgeThreshold = cv.argcheck(t, argRules)

        C.ORB_setEdgeThreshold(self.ptr, edgeThreshold)
    end

    function ORB:getEdgeThreshold()
        return C.ORB_getEdgeThreshold(self.ptr)
    end

    function ORB:setFirstLevel(t)
        local argRules = {
            {"firstLevel", required = true}
        }
        local firstLevel = cv.argcheck(t, argRules)

        C.ORB_setFirstLevel(self.ptr, firstLevel)
    end

    function ORB:getFirstLevel()
        return C.ORB_getFirstLevel(self.ptr)
    end

    function ORB:setWTA_K(t)
        local argRules = {
            {"wta_k", required = true}
        }
        local wta_k = cv.argcheck(t, argRules)

        C.ORB_setWTA_K(self.ptr, wta_k)
    end

    function ORB:getWTA_K()
        return C.ORB_getWTA_K(self.ptr)
    end

    function ORB:setScoreType(t)
        local argRules = {
            {"scoreType", required = true}
        }
        local scoreType = cv.argcheck(t, argRules)

        C.ORB_setScoreType(self.ptr, scoreType)
    end

    function ORB:getScoreType()
        return C.ORB_getScoreType(self.ptr)
    end

    function ORB:setPatchSize(t)
        local argRules = {
            {"patchSize", required = true}
        }
        local patchSize = cv.argcheck(t, argRules)

        C.ORB_setPatchSize(self.ptr, patchSize)
    end

    function ORB:getPatchSize()
        return C.ORB_getPatchSize(self.ptr)
    end

    function ORB:setFastThreshold(t)
        local argRules = {
            {"fastThreshold", required = true}
        }
        local fastThreshold = cv.argcheck(t, argRules)

        C.ORB_setFastThreshold(self.ptr, fastThreshold)
    end

    function ORB:getFastThreshold()
        return C.ORB_getFastThreshold(self.ptr)
    end
end

-- MSER

do 
    local MSER = cv.newTorchClass('cv.MSER', 'cv.Feature2D')

    function MSER:__init(t)
        local argRules = {
            {"_delta", default = 5},
            {"_min_area", default = 60},
            {"_max_area", default = 14400},
            {"_max_variation", default = 0.25},
            {"_min_diversity", default = 0.2},
            {"_max_evolution", default = 200},
            {"_area_threshold", default = 1.01},
            {"_min_margin", default = 0.003},
            {"_edge_blur_size", default = 5}   
        }
        local _delta, _min_area, _max_area, _max_variation, _min_diversity, _max_evolution,
                _area_threshold, _min_margin, _edge_blur_size = cv.argcheck(t, argRules)

        self.ptr = ffi.gc(C.MSER_ctor(_delta, _min_area, _max_area, _max_variation, _min_diversity, _max_evolution,
                                _area_threshold, _min_margin, _edge_blur_size),
                                Classes.Algorithm_dtor)    
    end

    function MSER:setDelta(t)
        local argRules = {
            {"delta", required = true}
        }
        local delta = cv.argcheck(t, argRules)

        C.MSER_setDelta(self.ptr, delta)
    end

    function MSER:getDelta()
        return C.MSER_getDelta(self.ptr)
    end

    function MSER:setMinArea(t)
        local argRules = {
            {"minArea", required = true}
        }
        local minArea = cv.argcheck(t, argRules)

        C.MSER_setMinArea(self.ptr, minArea)
    end

    function MSER:getMinArea()
        return C.MSER_getMinArea(self.ptr)
    end

    function MSER:setMaxArea(t)
        local argRules = {
            {"MaxArea", required = true}
        }
        local MaxArea = cv.argcheck(t, argRules)

        C.MSER_setMaxArea(self.ptr, MaxArea)
    end

    function MSER:getMaxArea()
        return C.MSER_getMaxArea(self.ptr)
    end
end







function cv.AGAST(t)
    local argRules = {
        {"image", required = true},
        {"threshold", required = true},
        {"nonmaxSuppression", default = true}
    }
    local image, threshold, nonmaxSuppression = cv.argcheck(t, argRules)

    return C.AGAST(cv.wrap_tensor(image), threshold, nonmaxSuppression)
end

return cv