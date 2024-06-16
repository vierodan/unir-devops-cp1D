
# Obtener los parámetros de salida de AWS CloudFormation
outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-staging --region us-east-1 | jq '.Stacks[0].Outputs')

# Función para extraer el valor basado en la clave
extract_value() {
    echo $outputs | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

# Extraer los valores
base_url_api=$(extract_value "BaseUrlApi")
delete_todo_api=$(extract_value "DeleteTodoApi")
list_todos_api=$(extract_value "ListTodosApi")
update_todo_api=$(extract_value "UpdateTodoApi")
get_todo_api=$(extract_value "GetTodoApi")
create_todo_api=$(extract_value "CreateTodoApi")

# Imprimir los valores
echo "Base URL of API: $base_url_api"
echo "Delete TODO API: $delete_todo_api"
echo "List TODOs API: $list_todos_api"
echo "Update TODO API: $update_todo_api"
echo "Get TODO API: $get_todo_api"
echo "Create TODO API: $create_todo_api"
