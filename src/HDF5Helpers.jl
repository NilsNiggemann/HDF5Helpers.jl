module HDF5Helpers
using HDF5

include("reading.jl")
export h5keys,getKeyswith,readGroupElements,ArrayReadGroupElements,readLastGroupElements,getReadablekeys,repairHDF5File,joinGroup

include("H5merge.jl")
export getSourceFilesWith,h5write,h5Merge,H5mergeFiles,allOccurIn,findNames,NameFilter,OnlyIndex
end # module
