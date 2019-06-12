SELECT * FROM (

    SELECT DISTINCT
        0 AS ordinal_position,
        CASE WHEN '${CUSTOM_PRIMARY_KEY}' != '' THEN '${CUSTOM_PRIMARY_KEY}' || ' AS custom_primary_key' ELSE  'NULL' || ' as custom_primary_key'  END::varchar(255) AS fields,
		CASE WHEN '${CUSTOM_PRIMARY_KEY}' != '' THEN '${CUSTOM_PRIMARY_KEY}' ELSE 'NULL' END::varchar(255) AS casting,
		'varchar(255)'::varchar(50) AS field_type,
		'{"name": "custom_primary_key","type":["null", "string"], "default": null}'::varchar(255) AS json,
        'custom_primary_key'::varchar(50) AS column_name,
        1 AS column_key

	UNION ALL

    SELECT DISTINCT
        ordinal_position,
        CASE
            WHEN data_type = 'date' THEN 'TO_CHAR ( ' || column_name || ' , ' || chr(39) || 'YYYY-MM-DD' ||  chr(39) || ') as ' || column_name
            WHEN data_type IN ( 'timestamp with time zone', 'timestamp without time zone' ) THEN 'TO_CHAR ( ' || column_name || ' , ' || chr(39) || 'YYYY-MM-DD HH24:MI:SS ' || '${TIMEZONE_OFFSET}' || chr(39) || ') as ' || column_name
            WHEN data_type IN ( '"char"', 'character varying', 'text' ) then  column_name || ' as ' || column_name
            ELSE column_name
        END::varchar(255) AS fields,
        CASE
            WHEN data_type = 'date' THEN 'TO_CHAR ( ' || column_name || ' , ' || chr(39) || 'YYYY-MM-DD' ||  chr(39) || ')'
            WHEN data_type IN ( 'timestamp with time zone', 'timestamp without time zone' ) THEN 'TO_CHAR ( ' || column_name || ' , ' || chr(39) || 'YYYY-MM-DD HH24:MI:SS ' || '${TIMEZONE_OFFSET}' || chr(39) || ')'
            WHEN data_type IN ( '"char"', 'character varying', 'text' ) then  column_name
            ELSE column_name
        END::varchar(255) AS casting,
        CASE data_type
            WHEN 'smallint'		                 THEN 'smallint'
            WHEN 'integer'		                 THEN 'int'
            WHEN 'bigint' 		                 THEN 'bigint'
            WHEN '"char"'			             THEN 'varchar'||'(' || COALESCE( character_maximum_length, 255 ) ||')'
            WHEN 'character varying'             THEN 'varchar'||'(' || COALESCE( character_maximum_length, 255 ) ||')'
            WHEN 'text'			                 THEN 'varchar(65535)'
            WHEN 'date'			                 THEN 'varchar(10)'
            WHEN 'timestamp with time zone'		 THEN 'varchar(25)'
            WHEN 'timestamp without time zone'	 THEN 'varchar(19)'
            WHEN 'time without time zone'	     THEN 'varchar(19)'
            WHEN 'double precision'	             THEN CASE '${IS_SPECTRUM}' WHEN '1' THEN 'double precision' ELSE 'double' END
            WHEN 'real'	                         THEN CASE '${IS_SPECTRUM}' WHEN '1' THEN 'double precision' ELSE 'double' END
            WHEN 'numeric'		                 THEN 'decimal'||'('|| COALESCE(  numeric_precision, 16 ) ||','|| COALESCE(  numeric_scale, 4 ) ||')'
            WHEN 'boolean' 		                 THEN 'boolean'
        END::varchar(50) AS field_type,
		( '{"name": "' || column_name ||  '","type":' ||
            CASE
                WHEN data_type IN ( 'smallint', 'integer') THEN '["null", "int"]'
                WHEN data_type IN ( 'bigint' ) THEN '["null", "long"]'
                WHEN data_type IN ( '"char"', 'character varying', 'text' ) THEN '["null", "string"]'
                WHEN data_type IN ( 'real', 'double precision' ) THEN '["null", "double"]'
                WHEN data_type IN ( 'date', 'timestamp with time zone', 'timestamp without time zone', 'time without time zone' ) THEN '["null", "string"]'
                WHEN data_type IN ( 'numeric' ) THEN '["null", {"type":"fixed", "name": "' || column_name || '", "size":' || round( COALESCE(  numeric_precision, 16 ) / 2, 0 ) || ', "logicalType": "decimal", "precision":' || COALESCE(  numeric_precision, 16 ) || ', "scale":' || COALESCE(  numeric_scale, 4 ) || '}]'
                WHEN data_type = 'boolean' THEN '["null", "boolean"]'
            END ||', "default": null}' ) AS json,
		lower( column_name )::varchar(50) AS column_name,
        0 AS column_key
    FROM
		information_schema.columns c
   	WHERE
		lower( c.table_schema ) = lower('${INPUT_TABLE_SCHEMA}')
   		AND
		lower( c.table_name ) = lower('${INPUT_TABLE_NAME}')

    UNION ALL

    SELECT
        998 AS ordinal_position,
        ( 'to_char( SYSDATE,' || chr(39) || 'YYYY-MM-DD HH24:MI:SS ' || '${TIMEZONE_OFFSET}' || chr(39) || ') as etl_load_date' )::varchar(255) AS fields,
		( 'to_char( SYSDATE,' || chr(39) || 'YYYY-MM-DD HH24:MI:SS ' || '${TIMEZONE_OFFSET}' || chr(39) || ')' )::varchar(255) AS casting,
        'varchar(19)'::varchar(50) AS field_type,
  		'{"name": "etl_load_date","type":["null", "string"], "default": null}' AS json,
        'etl_load_date'::varchar(50) 				AS column_name,
        0 											AS column_key
) x
ORDER BY x.ordinal_position
