-- Drop foreign key first so that we can drop the index next.
SET @FOREIGN_KEY_ADDON_ID := (
    SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE WHERE
        TABLE_SCHEMA = (SELECT DATABASE()) AND
        TABLE_NAME = 'update_counts' AND
        COLUMN_NAME = 'addon_id');

SET @QUERY_DROP_FOREIGN_KEY_ADDON_ID = IF(
    @FOREIGN_KEY_ADDON_ID IS NOT NULL,
    CONCAT('ALTER TABLE update_counts DROP FOREIGN KEY ', @FOREIGN_KEY_ADDON_ID, ';'),
    'SELECT 0;');

PREPARE stmt FROM @QUERY_DROP_FOREIGN_KEY_ADDON_ID;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Now drop old index, if it exists.

-- Drop addon_date_idx (addon_id, date) index.
-- Set to index_name (addon_date_idx) or NULL if it doesn't exist
SET @KEY_ADDON_DATE_IDX := (
    SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE
        TABLE_SCHEMA = (SELECT DATABASE()) AND
        TABLE_NAME = 'update_counts' AND
        INDEX_NAME = 'addon_date_idx'
    -- Need the limit 1 here because the query will match two columns
    -- because the index is a composite index on (addon_id, date)
    -- and since we re-use it below in the prepared-statement we want
    -- only the name.
    LIMIT 1);

SET @QUERY_DROP_KEY_ADDON_DATE_IDX = IF(
    @KEY_ADDON_DATE_IDX IS NOT NULL,
    CONCAT('ALTER TABLE update_counts DROP KEY ', @KEY_ADDON_DATE_IDX, ';'),
    'SELECT 0;');

PREPARE stmt FROM @QUERY_DROP_KEY_ADDON_DATE_IDX;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- Drop addon_and_count (addon_id, count) index.

-- Set to index_name (addon_date_idx) or NULL if it doesn't exist
SET @KEY_ADDON_AND_COUNT := (
    SELECT INDEX_NAME FROM information_schema.STATISTICS WHERE
        TABLE_SCHEMA = (SELECT DATABASE()) AND
        TABLE_NAME = 'update_counts' AND
        INDEX_NAME = 'addon_and_count'
    -- Need the limit 1 here because the query will match two columns
    -- because the index is a composite index on (addon_id, date)
    -- and since we re-use it below in the prepared-statement we want
    -- only the name.
    LIMIT 1);

SET @QUERY_DROP_KEY_ADDON_DATE_IDX = IF(
    @KEY_ADDON_DATE_IDX IS NOT NULL,
    CONCAT('ALTER TABLE update_counts DROP KEY ', @KEY_ADDON_DATE_IDX, ';'),
    'SELECT 0;');

PREPARE stmt FROM @QUERY_DROP_KEY_ADDON_DATE_IDX;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- TODO: Remove index from `date`

-- First create the foreign key that we dropped earlier
ALTER TABLE `update_counts` ADD CONSTRAINT `addon_id_refs_id_4420ac75` FOREIGN KEY (`addon_id`) REFERENCES `addons` (`id`);

-- Now create our new, proper index.
ALTER TABLE `update_counts` ADD CONSTRAINT `update_counts_date_6599adc5ae77ac23_uniq` UNIQUE (`date`, `addon_id`)
