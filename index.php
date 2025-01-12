<?php
#phpinfo();
// Connect to the database
$dbconn = pg_connect("host=db port=5432 dbname=name_db user=user_db password=pass_db");
// Show the client and server versions
print_r(pg_version($dbconn));