<%@page import="web.jsp09.model.BoardDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 수정 pro</title>
</head>
<% request.setCharacterEncoding("UTF-8"); %>
<jsp:useBean id="article" class="web.jsp09.model.BoardDTO" />
<jsp:setProperty property="*" name="article"/>
<%
	// 페이지넘도 뽑아놓기 
	String pageNum = request.getParameter("pageNum");

	// 넘어오는 데이터 num, writer, subject, email, content, pw 
	//DB에 article 던져주며 업데이트 시키기 
	BoardDAO dao = new BoardDAO(); 
	int result = dao.updateArticle(article); 
	if(result == 1){
		String uri = "list.jsp?pageNum=" + pageNum;
		response.sendRedirect(uri); 
		// content로 이동하고 싶을경우에는 글 고유번호 같이 보내기 
		// "content.jsp?num=" + article.getNum(); 
	}else{ %>
		<script>
			alert("비밀번호가 맞지 않습니다.");
			history.go(-1);
		</script>
<%	}
%>
<body>

</body>
</html>