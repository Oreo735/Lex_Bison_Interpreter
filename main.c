#include "main.h"

int main(int argc, char **argv)
{
	if (argc < 2)
	{
		PRINT_ERR("Argument Error: Empty arguments list.\n");
		exit(0);
	}
	if (!fileNameCheck(argv[1]))
	{
		PRINT_ERR("Argument Error: Incorrect file extention.\n");
	}
	input_file = argv[1];
	FILE_OPEN_CHECK(yyin, argv[1]);

	int err = yyparse();
	if (err)
	{
		fprintf(stdout, "Parse Failed.");
	}
	else
	{
		fprintf(stdout, "Parse Completed Successfully.\n");
	}

	return 0;
}

/* Check if the file name is correct */
bool fileNameCheck(char *fileName)
{
	int nameLength = strlen(fileName);
	int isAllUpperSle = !strcmp(fileName + strlen(fileName) - 4, ".SLE");
	int isAllLowerSle = !strcmp(fileName + strlen(fileName) - 4, ".sle");

	return (nameLength > 4 && (isAllUpperSle || isAllLowerSle));
}

/**
 * @brief Generic semi-safe allocation. Uses malloc as basis.
 *
 * @param size  Size of allocated memory for.
 * @return void* Pointer to a head allocated memory.
 */
void *checked_malloc(unsigned int size)
{
	void *ret;
	ret = malloc(size);
	if (!ret)
	{
		fprintf(stderr, "ERROR: Memory allocation failed");
		exit(1);
	}
	return ret;
}

/**
 * @brief Insert new id to the list.
 *
 * @param id
 * @param type
 */
void insertToTable(const char *id, Number type)
{
	Node *isExist = findById(id);
	if (isExist != NULL)
	{
		if (isExist->visited == FALSE)
		{
			fprintf(stderr, "ERROR: Symbol %s already defined.\n", id);
			isExist->visited = TRUE;
		}
		return;
	}
	Node *new_elem = ALLOC(Node, 1);
	strcpy(new_elem->id, id);
	new_elem->attr.type = type.type;
	new_elem->visited = FALSE;
	new_elem->next = smb_list.head;
	smb_list.head = new_elem;
}

/**
 * @brief Assign a value to an already existant id.
 *
 * @param id
 * @param val
 */
void assignOp(const char *id, Number val)
{
	Node *isExist = findById(id);
	if (!isExist)
	{
		CHECK_EXIST(isExist, id);
		return;
	}
	if (isExist->attr.type == FLOAT)
	{
		isExist->attr.fval = val.type == FLOAT ? val.fval : (float)val.ival;
	}
	else
	{
		isExist->attr.ival = val.type == FLOAT ? (int)val.fval : val.ival;
	}
	return;
}

void getOpp(const char *id, Number val)
{
	Node *isExist = findById(id);
	CHECK_EXIST(isExist, id);
}

/**
 * @brief Search an id by name.
 *
 * @param id id name.
 * @return Node* A pointer to the node containing the is.
 */
Node *findById(const char *id)
{
	Node *temp_head = smb_list.head;
	while (temp_head)
	{
		if (!strcmp(id, temp_head->id))
		{
			return temp_head;
		}
		temp_head = temp_head->next;
	}
	return NULL;
}

/**
 * @brief Get the Value of id By id name.
 *
 * @param id
 * @return Number
 */
Number getValueById(const char *id)
{
	Node *isExist = findById(id);
	if (!isExist)
	{
		CHECK_EXIST(isExist, id);
		Number err;
		err.type = ERROR;
		return err;
	}
	return isExist->attr;
}

/**
 * Check if an undefined variable already in the undefined list
 */
bool isUndefinedExist(const char *id)
{

	undeclared *head = error_list.head;
	while (head)
	{
		if (!strcmp(id, head->id))
		{
			return TRUE;
		}
		head = head->next;
	}
	return FALSE;
}

/**
 * insert to the undefined list
 */
void insertToUndeclaredTable(const char *id)
{
	undeclared *new_name = ALLOC(undeclared, 1);
	strcpy(new_name->id, id);
	new_name->next = error_list.head;
	error_list.head = new_name;
}

/**
 * Print the given expression
 */
void printExpression(Number num)
{
	switch (num.type)
	{
	case INTEGER:
		printf("%d", num.ival);
		return;
	case FLOAT:
		printf("%f", num.fval);
		return;
	case ERROR:
		return;
	}
}

/**
 * Calculates a boolean expression
 */
bool boolExp(Number lhs, char opr, Number rhs)
{
	double left = lhs.type == INTEGER ? lhs.ival : lhs.fval;
	double right = rhs.type == INTEGER ? rhs.ival : rhs.fval;
	switch (opr)
	{
	case '<':
		return left < right ? TRUE : FALSE;
	case '>':
		return left > right ? TRUE : FALSE;
	case '!':
		return left != right ? TRUE : FALSE;
	case '=':
		return left == right ? TRUE : FALSE;
	case '&':
		return left && right ? TRUE : FALSE;
	case '~':
		return left || right ? TRUE : FALSE;
	}
}

/**
 * @brief Preforms addition operation on two ids.
 *
 * @param lhs
 * @param opr
 * @param rhs
 * @return Number
 */
Number addOp(Number lhs, char opr, Number rhs)
{
	double left = lhs.type == INTEGER ? (double)lhs.ival : lhs.fval;
	double right = rhs.type == INTEGER ? (double)rhs.ival : rhs.fval;
	Number res;
	right = (opr == '-') ? -right : right;
	double ans = left + right;
	if (lhs.type == INTEGER && rhs.type == INTEGER)
	{
		res.type == INTEGER;
		res.ival = (int)ans;
	}
	else
	{
		res.type == FLOAT;
		res.fval = ans;
	}
	return res;
}

/**
 * @brief Preforms multiplication operation on two ids.
 *
 * @param lhs
 * @param opr
 * @param rhs
 * @return Number
 */
Number mulOp(Number lhs, char opr, Number rhs)
{
	double left = lhs.type == INTEGER ? (double)lhs.ival : lhs.fval;
	double right = rhs.type == INTEGER ? (double)rhs.ival : rhs.fval;
	Number res;
	if (lhs.type == INTEGER && rhs.type == INTEGER)
	{
		res.type == INTEGER;
	}
	switch (opr)
	{
	case '*':
		(res.type == INTEGER) ? (res.ival = (int)(left * right)) : (res.fval = left * right);
		break;
	case '/':
		if (right == 0)
		{
			fprintf(stderr, " ERROR: Can't divide by zero.\n");
			break;
		}
		(res.type == INTEGER) ? (res.ival = (int)(left / right)) : (res.fval = left / right);
		break;
	case '%':
		if (res.type == FLOAT)
		{
			fprintf(stderr, " ERROR: Can't preform operation MOD on floating point values.\n");
			break;
		}
		else
		{
			res.ival = (int)left % (int)right;
			break;
		}
	}
	return res;
}