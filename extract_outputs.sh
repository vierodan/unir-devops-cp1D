
# Get outputs for AWS CloudFormation
outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

# Function for extract URL's
extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

# Extract values and asign toenvironment variables
BASE_URL_API=(extract_value "BaseUrlApi")
DELETE_TODO_API=(extract_value "DeleteTodoApi")
LIST_TODOS_API=(extract_value "ListTodosApi")
UPDATE_TODO_API=(extract_value "UpdateTodoApi")
GET_TODO_API=(extract_value "GetTodoApi")
CREATE_TODO_API=(extract_value "CreateTodoApi")
