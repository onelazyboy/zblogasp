﻿<%@ LANGUAGE="VBSCRIPT" CODEPAGE="65001"%>
<% Option Explicit %>
<% 'On Error Resume Next %>
<% Response.Charset="UTF-8" %>
<!-- #include file="..\..\c_option.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_function.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_system_lib.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_system_base.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_system_event.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_system_manage.asp" -->
<!-- #include file="..\..\..\zb_system\function\c_system_plugin.asp" -->
<!-- #include file="..\p_config.asp" -->
<!-- #include file="function.asp" -->

<%
Call System_Initialize()
'检查非法链接
Call CheckReference("")
'检查权限
If BlogUser.Level>1 Then Call ShowError(6)
If CheckPluginState("ReplaceWord")=False Then Call ShowError(48)
BlogTitle="敏感词替换器"
replaceword.init()
Dim min,max,i
min=0
max=replaceword.words.length-1
%>
<!--#include file="..\..\..\zb_system\admin\admin_header.asp"-->
<style type="text/css">
td input[type="text"] {
	width: 93%
}
</style>
<script type="text/javascript" src="jquery.form.js" language="javascript"></script>
<script type="text/javascript" language="javascript">var New=0;</script>

<!--#include file="..\..\..\zb_system\admin\admin_top.asp"-->
        <div id="divMain">
          <div id="ShowBlogHint">
            <%Call GetBlogHint()%>
          </div>
          <div class="divHeader"><%=BlogTitle%></div>
          <div class="SubMenu"></div>
          <div id="divMain2"> 
            
            <ul>
              <li>1. 为不影响程序效率，请不要设置过多不需要的过滤内容。</li>
              <li>2. 程序将对新发布的文章和评论进行过滤，原有老评论不受影响。</li>
            </ul>
            <form id="form1" method="post" action="save.asp">
              <table width="100%" border="0">
                <tr height="32">
                  <th width="20">&nbsp;</th>
                  <th width="50">正则</th>
                  <th width="200">关键词</th>
                  <th width="200">替换词</th>
                  <th>注释</th>
                </tr>
                <%For i=min To max%>
                <tr height="32">
                  <td><a href="javascript:;" class="delete button" _id="<%=i%>">
                  <img src="../../../zb_system/IMAGE/ADMIN/delete.png" width="16" height="16" alt="删除"/>
                  </a></td>
                  <td><input type="text" id="exp_<%=i%>" name="exp_<%=i%>" value="<%=TransferHTML(replaceword.regex(i),"[html-format]")%>" class="checkbox"/></td>
                  <td><input type="text" id="str_<%=i%>" name="str_<%=i%>" value="<%=TransferHTML(replaceword.str(i),"[html-format]")%>"/></td>
                  <td><input type="text" id="rep_<%=i%>" name="rep_<%=i%>" value="<%=TransferHTML(replaceword.rep(i),"[html-format]")%>"/></td>
                  <td><input type="text" id="des_<%=i%>" name="des_<%=i%>" value="<%=TransferHTML(replaceword.des(i),"[html-format]")%>"/></td>
                </tr>
                <%Next%>
                <tr height="32">
                  <td><a href="javascript:;" class="new"><img src="../../../zb_system/IMAGE/ADMIN/page_copy.png" width="16" height="16" alt="新建"/></a></td>
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                  <td>&nbsp;</td>
                </tr>
              </table>
              <p>&nbsp;</p>
              <input type="submit" class="button" value="提交"/>
            </form>
          </div>
        </div>
        <div id="dialog" style="display:none">
        </div>
        <script type="text/javascript">
			ActiveTopMenu("aPlugInMng");
			$(document).ready(function(){
				bmx2table();
				$("form").submit(function(){
					$(this).ajaxForm(function(s){
						var j=eval("("+s+")");
						//alert(j.success);
						if(j.success){showDialog("保存成功！")}else{showDialog("保存失败，错误ID："+j.error)}
					});
					return false;
				});
				bindEvent();
				$(".new").click(function(){
					var mmm='<tr height="32">'+
                 		 '<td><a href="javascript:;" class="delete button" _id="new">'+
						 '<img src="../../../zb_system/IMAGE/ADMIN/delete.png" width="16" height="16" alt="删除"/>'+
						 '</a></td>'+
						 '<td><input type="text" id="exp_new" name="exp_'+New+'" value="False" class="checkbox"/></td>'+
						 '<td><input type="text" id="str_new" name="str_'+New+'" value=""/></td>'+
						 '<td><input type="text" id="rep_new" name="rep_'+New+'" value=""/></td>'+
						 '<td><input type="text" id="des_new" name="des_'+New+'" value=""/></td>'+
						 '</tr>';
					$(this).parent().parent().before(mmm);
					bindEvent();
					if(!(($.browser.msie)&&($.browser.version)=='6.0')){
						$('input.checkbox').css("display","none");
						$('input.checkbox[value="True"]').after('<span class="imgcheck imgcheck-on"></span>');
						$('input.checkbox[value="False"]').after('<span class="imgcheck"></span>');
					}else{
						$('input.checkbox').attr('readonly','readonly');
						$('input.checkbox').css('cursor','pointer');
						$('input.checkbox').click(function(){  if($(this).val()=='True'){$(this).val('False')}else{$(this).val('True')} })
					}

					$('span.imgcheck').click(function(){changeCheckValue(this)})

					bmx2table();
				})
			});
			function bindEvent(){
					$(".delete").click(function() {
					var _this=$(this);
					if(_this.attr("_id")=="new"){_this.parent().parent().remove();bmx2table();return false;}
                    $.post("save.asp?act=delete"
						,{"id":_this.attr("_id")}
						,function(s){
							var j=eval("("+s+")");
							if(j.success){
								showDialog("删除成功！","提示",function(){location.reload();});
								//_this.parent().parent().remove();
								//bmx2table();
							}else{
								showDialog("删除失败，错误ID："+j.error)
							}
						}
					)
                });
			}
			function showDialog(text,title,enter){
				var j=$('#dialog');
				j.html(text);
				j.dialog({
					modal: true,
					title: (title==""?"提示":title),
					buttons: {
						"确定": (enter==""?function() {$(this).dialog("close");}:enter)
					}
				})
			}
        </script>
        <!--#include file="..\..\..\zb_system\admin\admin_footer.asp"-->

<%Call System_Terminate()%>
