
outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

export BASE_URL_API=$(extract_value "BaseUrlApi")
export DELETE_TODO_API=$(extract_value "DeleteTodoApi")
export LIST_TODOS_API=$(extract_value "ListTodosApi")
export UPDATE_TODO_API=$(extract_value "UpdateTodoApi")
export GET_TODO_API=$(extract_value "GetTodoApi")
export CREATE_TODO_API=$(extract_value "CreateTodoApi")
