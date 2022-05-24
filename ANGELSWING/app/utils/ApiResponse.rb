class ApiResponse
	
	CODE = {
		:SUCCESS => "INFO-200",
		:NO_DATA => "INFO-210",
		:DELETED => "INFO-400",

		:INVALID_ACCOUNT => "ERROR-010",
		:PARAMETER_MISSING => "ERROR-300",
		:INVALID_VALUE => "ERROR-310",
		:DUP_ENTRY => "ERROR-400",
		:PERMISSON_ERROR => "ERROR-410",
		:DATA_NOT_EXIST => "ERROR-420",
		:DB_ERROR => "ERROR-430",
		:SERVER_ERROR => "ERROR-500"
	}
	
	MESSAGE = {
		:SUCCESS => "Successfully processed.",
		:NO_DATA => "No Data.",
		:DELETED => "Deleted.",
		
		:INVALID_ACCOUNT => "Email or password is not valid.",
		:PARAMETER_MISSING => "Required parameter is missing. Please See the Request document.",
		:INVALID_VALUE => "Value is invalid. Please See the Request document.",
		:DUP_ENTRY => "Duplicate entry",
		:PERMISSON_ERROR => "You do not have permission.",
		:DATA_NOT_EXIST => "Data does not exist.",
		:DB_ERROR => "DB ERROR.",
		:SERVER_ERROR => "Internal Server Error. Please contact the customer center."
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