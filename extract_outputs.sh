input_environment = $1
input_region = $2

echo "Input 1: $input_environment"
echo "Input 2: $input_region"


outputs=$(aws cloudformation describe-stacks --stack-name todo-list-aws-$input_environment --region $input_region | jq '.Stacks[0].Outputs')

extract_value() {
    echo "$outputs" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"
}

BASE_URL_API=$(extract_value "BaseUrlApi")
DELETE_TODO_API=$(extract_value "DeleteTodoApi")
LIST_TODOS_API=$(extract_value "ListTodosApi")
UPDATE_TODO_API=$(extract_value "UpdateTodoApi")
GET_TODO_API=$(extract_value "GetTodoApi")
CREATE_TODO_API=$(extract_value "CreateTodoApi")

echo $BASE_URL_API > base_url_api.tmp
echo $DELETE_TODO_API > delete_todo_api.tmp
echo $LIST_TODOS_API > list_todos_api.tmp
echo $UPDATE_TODO_API > update_todo_api.tmp
echo $GET_TODO_API > get_todo_api.tmp
echo $CREATE_TODO_API >create_todo_api.tmp
