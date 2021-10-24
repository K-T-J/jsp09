<%@page import="web.jsp09.model.BoardDTO"%>
<%@page import="web.jsp09.model.BoardDAO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시글 수정 form</title>
	<link href="style.css" rel="stylesheet" type="text/css">
</head>
<%
	// 컨텐트페이지에서 넘겨준 pageNum 꺼내 놓기 
	String pageNum = request.getParameter("pageNum");

	// 넘어온 글 고유 번호 꺼내서 
	int num = Integer.parseInt(request.getParameter("num"));
	// DB에서 해당 글 가져와 화면에 뿌려주기 
	BoardDAO dao = new BoardDAO(); 
	BoardDTO article = dao.getUpdateArticle(num); 
%>
<body>
	<br />
	<h1 align="center"> 게시글 수정 </h1>
	<form action="modifyPro.jsp?pageNum=<%=pageNum%>" method="post">
		<%-- 숨겨서 글 고유번호 값 전송 --%>
		<input type="hidden" name="num" value="<%=num %>" />
		<table>
			<tr>
				<td>작성자</td>
				<td align="left"><input type="text" name="writer" value="<%=article.getWriter() %>"/></td>
			</tr>
			<tr>
				<td>제  목</td>
				<td align="left"><input type="text" name="subject" value="<%=article.getSubject()%>"/></td>
			</tr>
			<tr>
				<td>e-mail</td>
				<td align="left"><input type="text" name="email" value="<%=article.getEmail()%>"/></td>
			</tr>
			<tr>
				<td>내  용</td>
				<td ><textarea rows="20" cols="60" name="content"><%=article.getContent()%></textarea></td>
			</tr>
			<tr>
				<td>비밀번호</td>
				<td align="left"><input type="password" name="pw" /></td>
			</tr>
			<tr>
				<td colspan="2" >
					<input type="submit" value="수정" />
					<input type="reset" value="재작성" />
					<input type="button" value="취소" onclick="window.location='content.jsp?num=<%=num%>&pageNum=<%=pageNum%>'" />
					<input type="button" value="리스트보기" onclick="window.location='list.jsp?pageNum=<%=pageNum%>'" />
				</td>
			</tr>
		</table>
	</form>
	
	
</body>
</html>