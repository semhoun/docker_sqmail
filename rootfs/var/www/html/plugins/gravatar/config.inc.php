<?php
// Per-user chooseable settings
$config['gravatar_enabled'] = true;
$config['gravatar_size'] = 128;
$config['gravatar_rating'] = 'g'; // Possible values 'g', 'pg', 'r', 'x'
$config['gravatar_custom'] = false;

// Server side configuration (uncomment to change)
$config['gravatar_https'] = true; // It is only server to server
// This should not be changed
//$config['gravatar_photo_api'] = '%s://www.gravatar.com/avatar/%m?s=%z&r=%r&d=404';

// For custom api fill this (see README.md for replacements)
// set 'gravatar_custom' to true to enable by default on each user.
// For security reasons user will not be permited to change this.
//$config['gravatar_custom_photo_api'] = 'http://www.example.com/avatars/%e.jpg?s=%z';
