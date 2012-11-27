<div style="clear: both;margin:0 0 0 15px;height:50px;">
<div id="fb-root"></div>
    <div class="fb-like" data-send="true" data-href="<%=request.getScheme() + "://" + request.getServerName()+request.getAttribute("javax.servlet.forward.request_uri")%>" data-width="450" data-show-faces="face" data-action="recommend"></div>
    <script>(function(d, s, id) {
  var js, fjs = d.getElementsByTagName(s)[0];
  if (d.getElementById(id)) return;
  js = d.createElement(s); js.id = id;
  js.src = "//connect.facebook.net/en_US/all.js#xfbml=1";
  fjs.parentNode.insertBefore(js, fjs);
}(document, 'script', 'facebook-jssdk'));</script>

<!-- Place this tag where you want the +1 button to render -->
<g:plusone size="medium" annotation="inline"></g:plusone>

<!-- Place this render call where appropriate -->
<script type="text/javascript">
  (function() {
    var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
    po.src = 'https://apis.google.com/js/plusone.js';
    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
  })();
</script>
</div>