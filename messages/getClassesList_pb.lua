-- Generated by protobuf; do not edit
local module = {}
local protobuf = require 'protobuf'

module.RESULT = protobuf.Descriptor()
module.RESULT_CLASSES_LIST_FIELD = protobuf.FieldDescriptor()

module.RESULT_CLASSES_LIST_FIELD.name = 'classes_list'
module.RESULT_CLASSES_LIST_FIELD.full_name = '.qlua.rpc.getClassesList.Result.classes_list'
module.RESULT_CLASSES_LIST_FIELD.number = 1
module.RESULT_CLASSES_LIST_FIELD.index = 0
module.RESULT_CLASSES_LIST_FIELD.label = 1
module.RESULT_CLASSES_LIST_FIELD.has_default_value = false
module.RESULT_CLASSES_LIST_FIELD.default_value = ''
module.RESULT_CLASSES_LIST_FIELD.type = 9
module.RESULT_CLASSES_LIST_FIELD.cpp_type = 9

module.RESULT.name = 'Result'
module.RESULT.full_name = '.qlua.rpc.getClassesList.Result'
module.RESULT.nested_types = {}
module.RESULT.enum_types = {}
module.RESULT.fields = {module.RESULT_CLASSES_LIST_FIELD}
module.RESULT.is_extendable = false
module.RESULT.extensions = {}

module.Result = protobuf.Message(module.RESULT)


module.MESSAGE_TYPES = {'Result'}
module.ENUM_TYPES = {}

return module
