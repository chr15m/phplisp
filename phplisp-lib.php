<?php
function phplisp_repr($value) {
  if (is_array($value)) {
    return var_export($value, true);
  }
  else{
    return $value;
  }
}
?>
