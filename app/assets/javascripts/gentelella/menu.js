/** ******  left menu  *********************** **/
$(function () {
    $('#sidebar-menu li ul').slideUp();
    $('#sidebar-menu li').removeClass('active');

    $('#sidebar-menu li').on('click touchstart', function() {
        var link = $('a', this).attr('href');

        if(link) {
            window.location.href = link;
        } else {
            if ($(this).is('.active')) {
                $(this).removeClass('active');
                $('ul', this).slideUp();
            } else {
                $('#sidebar-menu li').removeClass('active');
                $('#sidebar-menu li ul').slideUp();

                $(this).addClass('active');
                $('ul', this).slideDown();
            }
        }
    });

    $('#menu_toggle').click(function () {
        if ($('body').hasClass('nav-md')) {
            $('body').removeClass('nav-md').addClass('nav-sm');
            $('.left_col').removeClass('scroll-view').removeAttr('style');
            $('.sidebar-footer').hide();

            if ($('#sidebar-menu li').hasClass('active')) {
                $('#sidebar-menu li.active').addClass('active-sm').removeClass('active');
            }
        } else {
            $('body').removeClass('nav-sm').addClass('nav-md');
            $('.sidebar-footer').show();

            if ($('#sidebar-menu li').hasClass('active-sm')) {
                $('#sidebar-menu li.active-sm').addClass('active').removeClass('active-sm');
            }
        }
    });
});

/* Sidebar Menu active class */
$(function () {
    var url = window.location;
    $('#sidebar-menu a[href="' + url + '"]').parent('li').addClass('current-page');
    $('#sidebar-menu a').filter(function() {
    	var $a = $(this);
    	
        return this.href == url || url.toString().endsWith($a.attr("data-url-alias"));
    }).parent('li').addClass('current-page').parent('ul').slideDown().parent().addClass('active');
});
/** ******  /left menu  *********************** **/
