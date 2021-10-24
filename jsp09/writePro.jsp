<%@page import="web.jsp09.model.BoardDAO"%>
<%@page import="java.sql.Timestamp"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>글쓰기 pro</title>
</head>
<%
	request.setCharacterEncoding("UTF-8");
%>
<jsp:useBean id="article" class="web.jsp09.model.BoardDTO" /> <%--useBean은 DTO 객체생성만한것과 같은것이다. --%>
<jsp:setProperty property="*" name="article"/><%--넘어오는 데이터를 꺼내서 dto에 변수에 자동으로 넣기 --%>
<%
	// 넘어오는 데이터들을 제외한 나머지 채울 부분 채워주기 : writeForm에서 안넘어온 데이터 추가로 세팅
	// DAO한테 article 이라는 dto 객체를 던져주며 db테이블에 추가 시켜라 할건데
	// 안채워진 변수는 문제가 생기니 미리 여기서 채워줌
	article.setReg(new Timestamp(System.currentTimeMillis()));
	article.setReadcount(0);
	
	// DB에 article 객체 주면서 저장시키기 
	BoardDAO dao = new BoardDAO(); 
	dao.insertArticle(article); 
	
	// 게시판 목록으로 이동 
	response.sendRedirect("list.jsp");

%>

<body>

</body>
</html>