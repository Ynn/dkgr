<?php
date_default_timezone_set('America/Los_Angeles');
ignore_user_abort(true);
set_time_limit(0);

$repo          = '/www/#DOCKERNAME#';
$branch        = 'origin/master';
$output        = array();

// update github Repo
//$output[] = date('Y-m-d, H:i:s', time()) . "\n";
//$output[] = "GitHub Pull\n============================\n" . shell_exec('cd '.$repo.' && git fetch origin && git reset --hard '$branch.' && git submodule update --recursive 2>&1');

$dir = getcwd();
$cmd = 'nohup '.$dir.'/pull.sh '.$repo.' '.$branch.'>>'.$dir.'/pull.log 2>&1 &';
//echo $cmd;
echo shell_exec($cmd);
echo "processing";

// redirect output to logs
//file_put_contents(rtrim(getcwd(), '/').'/pull.log', implode("\n", $output) . "\n----------------------------\n", FILE_APPEND);
?>
