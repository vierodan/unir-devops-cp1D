
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

# Guardar las variables en un archivo de propiedades
cat <<EOF > env.properties
BASE_URL_API=$BASE_URL_API
DELETE_TODO_API=$DELETE_TODO_API
LIST_TODOS_API=$LIST_TODOS_API
UPDATE_TODO_API=$UPDATE_TODO_API
GET_TODO_API=$GET_TODO_API
CREATE_TODO_API=$CREATE_TODO_API
EOF

