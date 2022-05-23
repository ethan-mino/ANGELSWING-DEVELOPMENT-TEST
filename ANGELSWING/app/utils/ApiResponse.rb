class ApiResponse
	CODE = {
		"INFO-200" => "Successfully processed.",
		"INFO-210" => "No Data.",
		
		"ERROR-000" => "Email already exists.",
		"ERROR-010" => "Email or password is not valid.",
		
		"ERROR-300" => "Required parameter is missing. Please See the Request document.",
		"ERROR-310" => "Value is invalid. Please See the Request document.",
		
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