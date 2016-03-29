/** ******  right_col height flexible  *********************** **/
$(".right_col").css("min-height", $(window).height());
$(window).resize(function () {
    $(".right_col").css("min-height", $(window).height());
});
/** ******  /right_col height flexible  *********************** **/
