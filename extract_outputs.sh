
outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

BASE_URL_API=$(extract_value "BaseUrlApi")
DELETE_TODO_API=$(extract_value "DeleteTodoApi")
LIST_TODOS_API=$(extract_value "ListTodosApi")
UPDATE_TODO_API=$(extract_value "UpdateTodoApi")
GET_TODO_API=$(extract_value "GetTodoApi")
CREATE_TODO_API=$(extract_value "CreateTodoApi")

# Imprimir las variables en formato que puede ser leído por el shell
cat <<EOF
export BASE_URL_API=$BASE_URL_API
export DELETE_TODO_API=$DELETE_TODO_API
export LIST_TODOS_API=$LIST_TODOS_API
export UPDATE_TODO_API=$UPDATE_TODO_API
export GET_TODO_API=$GET_TODO_API
export CREATE_TODO_API=$CREATE_TODO_API
EOF

echo "Base URL of API: $BASE_URL_API"
echo "Delete TODO API: $DELETE_TODO_API"
echo "List TODOs API: $LIST_TODOS_API"
echo "Update TODO API: $UPDATE_TODO_API"
echo "Get TODO API: $GET_TODO_API"
echo "Create TODO API: $CREATE_TODO_API"
