<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.List"%>
<%@page import="web.jsp09.model.BoardDTO"%>
<%@page import="web.jsp09.model.BoardDAO"%>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<title>게시판</title>
	<link href="style.css" rel="stylesheet" type="text/css">
</head>
<%
	// ** 게시글 페이지 관련 정보 세팅 ** 
	// 한페이지에 보여줄 게시글의 수 (변수로만듬)#1
	int pageSize = 10; 

	// 현재 페이지 번호  #2
	String pageNum = request.getParameter("pageNum"); // 요청시 페이지번호가 넘어왔으면 꺼내서 담기. 
	if(pageNum == null){ // list.jsp 라고만 요청했을때, 즉 pageNum 파라미터 안넘어왔을때.
		pageNum = "1";//안넘어 왔으면 1페이지 보여줌 파라미터 주고받기 위해 문자로 해둔다
	}
	
	// 현재 페이지에 보여줄 게시글 시작과 끝 등등 정보 세팅 #3
	int currentPage = Integer.parseInt(pageNum); // 계산을 위해 현재페이지 숫자로 변환하여 저장 
	int startRow = (currentPage - 1) * pageSize + 1; //2페이지 누르면 11번쨰부터 게이글보이게 ex)넘어온값이 1이면 (1-1)*10+1 =1페이지
	int endRow = currentPage * pageSize; // 페이지 마지막 글번호
	
	
	// 게시판 글 가져오기  #4
	BoardDAO dao = new BoardDAO(); 
	// 전체 글의 개수 가져오기 #5
	int count = dao.getArticleCount();   // DB에 저장되어있는 전체 글의 개수를 가져와 담기
	System.out.println("count : " + count);
	
	
	// 글이 하나라도 있으면 글들을 다시 가져오기 #7
	List articleList = null; // 밖에서 사용가능하게 if문 시작 전에 미리 선언 #9
	
	if(count > 0){//게시글의 범위 / 게시글이 0보다 크면 게시글을 가져와라
		articleList = dao.getArticles(startRow, endRow); //#10 어디서 ~ 어디까지 가져와라
	}
	int number = count - (currentPage-1)*pageSize; 	//#12 게시판 목록에 뿌려줄 가상의 글 번호  

	// 날짜 출력 형태 패턴 생성 
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy.MM.dd HH:mm");
	
%>
<body>
	<br />
	<h1 align="center"> 게시판 </h1>
	<% if(count == 0){//#13게시글이 없으면 %>
	<table>
		<tr>
			<td><button onclick="window.location='writeForm.jsp'"> 글쓰기 </button></td>
		</tr>
		<tr>
			<td align="center">게시글이 없습니다.</td>
		</tr>
	</table>
	<%}else{//게시글이 있으면%>
	<table>
		<tr>
			<td colspan="5" align="right"><button onclick="window.location='writeForm.jsp'"> 글쓰기 </button></td>
		</tr>
		<tr>
			<td>No.</td>
			<td>제  목</td>
			<td> num / ref / re_step / re_level </td>
			<td>작성자</td>
			<td>시  간</td>
			<td>조회수</td>
		</tr>
		
		<%for(int i = 0; i < articleList.size(); i++){
			BoardDTO article = (BoardDTO)articleList.get(i); 
			%>
			<tr>
				<td><%= number-- %></td>
				<td align="left">
					<% // 답글 제목 들여쓰기 + > 화살표 이미지 추가 
						int wid = 0; 
						if(article.getRe_level() > 0) { // 0 이상이면 답글이다 
							wid = 10 * (article.getRe_level()); %>
							
							<img src="img/tabImg.PNG" width="<%=wid%>" />
							<img src="img/replyImg.png" width="11" /> 
					<%	}// if
					%>
			 		<a href="content.jsp?num=<%=article.getNum()%>&pageNum=<%=pageNum%>"> <%= article.getSubject() %> </a>
				</td>
				<td> <%=article.getNum()%> / <%=article.getRef()%> / <%=article.getRe_step()%> / <%=article.getRe_level()%> </td>
				<td><a href="mailto:<%=article.getEmail()%>"> <%= article.getWriter() %> </a></td>
				<td><%= sdf.format(article.getReg()) %></td>
				<td><%= article.getReadcount() %></td>
			</tr>
		<% }// for%>
	</table>
	<%}//else%>
	<br /> <br /> 
	<%-- 페이지 번호 --%>
	<div align="center">
	<% if(count > 0) {
		// 페이지 번호를 몇개까지 보여줄것인지 지정
		int pageBlock = 3; 
		// 총 몇페이지가 나오는지 계산 
		int pageCount = count / pageSize + (count % pageSize == 0 ? 0 : 1);
		// 현재 페이지에서 보여줄 첫번째 페이지번호 
		int startPage = (int)((currentPage-1)/pageBlock) * pageBlock + 1; 
		// 현재 페이지에서 보여줄 마지막 페이지번호 ( ~10, ~20, ~30...)
		int endPage = startPage + pageBlock - 1; 
		// 마지막에 보여줄 페이지번호는, 전체 페이지 수에 따라 달라질 수 있다. 
		// 전체 페이지수(pageCount)가 위에서 계산한 endPage(10단위씩)보다 작으면 
		// 전체 페이지수가 endPage가 된다. 
		if(endPage > pageCount) {endPage = pageCount;} 
		
		// 왼쪽 꺽쇄 : startPage 가 pageBlock(10)보다 크면 
		if(startPage > pageBlock) { %>
			<a href="list.jsp?pageNum=<%=startPage-pageBlock %>" class="pageNums"> &lt; &nbsp;</a>
	<%	}
		// 페이지 번호 뿌리기 
		for(int i = startPage; i <= endPage; i++){ %>
			<a href="list.jsp?pageNum=<%=i%>" class="pageNums"> &nbsp; <%= i %> &nbsp; </a>
	<%	}
		// 오른쪽 꺽쇄 : 전체 페이지 개수(pageCount)가 endPage(현재보는페이지에서의 마지막번호) 보다 크면 
		if(endPage < pageCount) { %>
			&nbsp; <a href="list.jsp?pageNum=<%=startPage+pageBlock%>" class="pageNums"> &gt; </a>
	<%	}
		
	}%>
	
	<h3 style="color:black"> 현재페이지 : <%= pageNum %></h3>
	
	</div>
	
	
	
</body>
</html>




