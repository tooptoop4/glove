SELECT * FROM (
	SELECT DISTINCT
		${PARTITION_FIELD_CASTING} AS partition_value
	FROM 
		${INPUT_TABLE_SCHEMA}.${INPUT_TABLE_NAME}
	WHERE 
		${WHERE_CONDITION_TO_RECOVER}
)x