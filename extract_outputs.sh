
# Get outputs for AWS CloudFormation
outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

# Function for extract URL's
extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

# Extract values and asign toenvironment variables
export BASE_URL_API=$(extract_value "BaseUrlApi")
export DELETE_TODO_API=$(extract_value "DeleteTodoApi")
export LIST_TODOS_API=$(extract_value "ListTodosApi")
export UPDATE_TODO_API=$(extract_value "UpdateTodoApi")
export GET_TODO_API=$(extract_value "GetTodoApi")
export CREATE_TODO_API=$(extract_value "CreateTodoApi")

# Print values
echo "Base URL of API: $BASE_URL_API"
echo "Delete TODO API: $DELETE_TODO_API"
echo "List TODOs API: $LIST_TODOS_API"
echo "Update TODO API: $UPDATE_TODO_API"
echo "Get TODO API: $GET_TODO_API"
echo "Create TODO API: $CREATE_TODO_API"

