<?php
header('Content-Type: application/json');
echo json_encode([
    'version' => PHP_VERSION,
    'sapi' => PHP_SAPI,
    'extensions' => get_loaded_extensions(),
], JSON_THROW_ON_ERROR);
