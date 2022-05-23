class ApiResponse
	CODE = {
		"INFO-200" => "Successfully processed.",
		"INFO-210" => "No Data.",
		
		"INFO-400" => "Deleted",
		
		"ERROR-010" => "Email or password is not valid.",
		
		"ERROR-300" => "Required parameter is missing. Please See the Request document.",
		"ERROR-310" => "Value is invalid. Please See the Request document.",
		
		"ERROR-400" => "Duplicate entry",
		"ERROR-410" => "You do not have permission.",
		"ERROR-420" => "Data does not exist.",
		"ERROR-430" => "DB ERROR.",
		
		"ERROR-500" => "Internal Server Error. Please contact the customer center."
	}
	
	def ApiResponse.response(code, data) # method that make a response 
		response = {
			result: {
				code: code, 
				message: CODE[code]
			}
		}

		unless data.nil?
			response[:data] = data
		end
		
		response
	end
end