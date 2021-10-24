<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>글쓰기 form</title>
	<link href="style.css" rel="stylesheet" type="text/css">
</head>
<%
	// DB에 담아줄 글 관련 정보 선언+초기화 
	// 글번호, 그룹, 정렬순서, 답글레벨 
	int num = 0, ref = 1, re_step = 0, re_level = 0;
	// num (새글 작성 0, 답글 1이상 답글다는 원본글의 고유번호)
	
	// 답글로 넘어왔을 경우 (num, ref, re_step, re_level 4개 들고 넘어옴)
	if(request.getParameter("num") != null){ // 넘어온 파라미터중 num으로 새글작성인지 답글작성인지 판단 
		// 정보 담기 
		num = Integer.parseInt(request.getParameter("num"));  // 27
		ref = Integer.parseInt(request.getParameter("ref"));  // 20 
		re_step = Integer.parseInt(request.getParameter("re_step")); // 2
		re_level = Integer.parseInt(request.getParameter("re_level"));  // 2
	}
%>
<body>
	<br />
	<h1 align="center"> 게시글 작성 </h1>
	<form action="writePro.jsp" method="post">
		<%-- 숨겨서 글 속성 값 전송 --%>
		<input type="hidden" name="num" value="<%=num %>" />
		<input type="hidden" name="ref" value="<%=ref %>" />
		<input type="hidden" name="re_step" value="<%=re_step %>" />
		<input type="hidden" name="re_level" value="<%=re_level %>" />
		<table>
			<tr>
				<td>작성자</td>
				<td align="left"><input type="text" name="writer" /></td>
			</tr>
			<tr>
				<td>제  목</td>
				<td align="left">
				<% if(request.getParameter("num") == null) { // 새글작성 %>				
					<input type="text" name="subject" />
				<%}else{ // 답글로 넘어왔을 경우 %>
					<input type="text" name="subject" value="[답글]" />
				<%} %>
				</td>
			</tr>
			<tr>
				<td>e-mail</td>
				<td align="left"><input type="text" name="email" /></td>
			</tr>
			<tr>
				<td>내  용</td>
				<td><textarea rows="20" cols="60" name="content"></textarea></td>
			</tr>
			<tr>
				<td>비밀번호</td>
				<td align="left"><input type="password" name="pw" /></td>
			</tr>
			<tr>
				<td colspan="2" >
					<input type="submit" value="저장" />
					<input type="reset" value="재작성" />
					<input type="button" value="리스트보기" onclick="window.location='list.jsp'" />
				</td>
			</tr>
		</table>
	</form>
	
</body>
</html>