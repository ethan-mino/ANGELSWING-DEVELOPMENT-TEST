class ApiResponse
	
	CODE = {
		:INF_SUCCESS => "INFO-200",
		:INF_NO_DATA => "INFO-210",
		:INF_DELETED => "INFO-400",
		
		:ERR_NEED_AUTH => "ERROR-000",
		:ERR_INVALID_ACCOUNT => "ERROR-010",
		:ERR_PARAM_MISSING => "ERROR-300",
		:ERR_INVALID_VALUE => "ERROR-310",
		:ERR_DUP_ENTRY => "ERROR-400",
		:ERR_PERMISSON => "ERROR-410",
		:ERR_NOT_EXIST => "ERROR-420",
		:ERR_DB => "ERROR-430",
		:ERR_SERVER => "ERROR-500"
	}
	
	MESSAGE = {
		:INF_SUCCESS => "Successfully processed.",
		:INF_NO_DATA => "No Data.",
		:INF_DELETED => "Deleted.",
		
		:ERR_NEED_AUTH => "Please Log in",
		:ERR_INVALID_ACCOUNT => "Email or password is not valid.",
		:ERR_PARAM_MISSING => "Required parameter is missing. Please See the Request document.",
		:ERR_INVALID_VALUE => "Value is invalid. Please See the Request document.",
		:ERR_DUP_ENTRY => "Duplicate entry",
		:ERR_PERMISSON => "You do not have permission.",
		:ERR_NOT_EXIST => "Data does not exist.",
		:ERR_DB => "DB ERROR.",
		:ERR_SERVER => "Internal Server Error. Please contact the customer center."
	}
	
	def ApiResponse.response(code, data) # method that make a response 
		response = {
			result: {
				code: CODE[code], 
				message: MESSAGE[code]
			}
		}

		unless data.nil?
			response[:data] = data
		end
		
		response
	end
end