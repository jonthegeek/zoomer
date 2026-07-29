# .pkg_abort works

    Code
      (expect_pkg_error_classes(.pkg_abort("This is a test error", c("subclass",
        "test_error")), "zoomer", "subclass", "test_error"))
    Output
      <error/zoomer-error-subclass-test_error>
      Error:
      ! This is a test error

# .pkg_warn works

    Code
      (expect_pkg_warning_classes(.pkg_warn("This is a test warning", c("subclass",
        "test_warning")), "zoomer", "subclass", "test_warning"))
    Output
      <warning/zoomer-warning-subclass-test_warning>
      Warning:
      This is a test warning

# .pkg_inform works

    Code
      (expect_pkg_message_classes(.pkg_inform("This is a test message", c("subclass",
        "test_message")), "zoomer", "subclass", "test_message"))
    Output
      <message/zoomer-message-subclass-test_message>
      Message:
      This is a test message

