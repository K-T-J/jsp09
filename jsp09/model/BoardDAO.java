package web.jsp09.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class BoardDAO {

	// 커넥션 기본세팅
	private Connection getConnection() throws Exception {
		Context ctx = new InitialContext();
		Context env = (Context)ctx.lookup("java:comp/env");
		DataSource ds = (DataSource)env.lookup("jdbc/orcl");
		return ds.getConnection();
	}
	
	// 게시글 전체 개수 가져오는 메서드 #6
	public int getArticleCount() {
		int count = 0; 
		Connection conn = null; 
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		
		try {
			conn = getConnection(); 
			String sql = "select count(*) from board";
			pstmt = conn.prepareStatement(sql);//쿼리문을 pstmt에 담기
			
			rs = pstmt.executeQuery(); //쿼리문 실행 -> rs에 담기
			if(rs.next()) {//값이 있다면 실행
				// count(*)은 결과를 숫자로 가져오며, 컬럼명대신 컬럼번호로 꺼내서 count 변수에 담기 
				count = rs.getInt(1);  
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return count;
	}
	
	//#7 게시글 범위만큼 가져오는 메서드 
	public List getArticles(int start, int end) {//#11 //1 ~ 10 까지 보여달라고 넘어왔다.
		Connection conn = null; 
		PreparedStatement pstmt = null; 
		ResultSet rs = null; 
		List articleList = null; 
		try {
			conn = getConnection();
			/*
			String sql = "select num,writer,subject,email,content,pw,reg,readcount,ref,re_step,re_level,r " 
			+ "from (select num,writer,subject,email,content,pw,reg,readcount,ref,re_step,re_level,rownum r " //정렬한거에 rownum을 추가해서 다시 정렬해주고
			+ "from (select num,writer,subject,email,content,pw,reg,readcount,ref,re_step,re_level " //첫번쨰 정렬을하고
			+ "from board order by ref desc, re_step asc) order by ref desc, re_step asc) where r >= ? and r <= ?"; //r 을 가지고 조건문을 건다
			*/
			String sql = "SELECT B.*,r FROM (SELECT A.*, rownum r FROM "
					+ "(select * from board order by ref desc, re_step ASC)A order by ref desc, re_step ASC)B where r >= ? and r <= ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, start);
			pstmt.setInt(2, end);
			rs = pstmt.executeQuery(); 
			if(rs.next()) { //결과가 있는지 체크 있으면 arraylist 생성 next하면 커서가 내려가니깐 do로 일단 뽑는다 그다음에 while로 검사한다.
				articleList = new ArrayList();  // 결과가 있으면 list 객체생성해서 준비 (나중에 null로 확인하기 위하여)
				do { // if문에서 rs.next() 실행되서 커서가 내려가버렸으니 do-while로 먼저 데이터 꺼내게 하기.
					BoardDTO article = new BoardDTO(); 
					article.setNum(rs.getInt("num")); //DB에서 꺼내온걸 DTO에 넣는다
					article.setWriter(rs.getString("writer"));
					article.setSubject(rs.getString("subject"));
					article.setEmail(rs.getString("email"));
					article.setContent(rs.getString("content"));
					article.setPw(rs.getString("pw"));
					article.setReg(rs.getTimestamp("reg"));
					article.setRef(rs.getInt("ref"));
					article.setRe_step(rs.getInt("re_step"));
					article.setRe_level(rs.getInt("re_level"));
					article.setReadcount(rs.getInt("readcount"));
					articleList.add(article); // 리스트에 추가 
				}while(rs.next());
			}// if
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return articleList;
	}
	
	// 글 저장 메서드 
	public void insertArticle(BoardDTO article) {
		Connection conn = null;
		PreparedStatement pstmt = null; 
		ResultSet rs = null;
		// 조정, 확인이 필요한 값들 미리 꺼내놓기 
		int num = article.getNum();			// 글번호(새글 0, 댓글 1이상=원본글의 고유번호) 		22
		int ref = article.getRef();			// 글 그룹  	1 								20
		int re_step = article.getRe_step();	// 정렬 순서 	0								2
		int re_level = article.getRe_level(); // 답글 레벨  0								2
		int forRef = 0; 					// DB에 저장할 글고유번호-ref 활용변수 
		
		try {
			conn = getConnection(); 
			// 글 고유번호중 가장 큰 수 가져오기 
			String sql = "select max(num) from board"; 
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery(); 
			// 게시글이 존재하면 가져온 가장 큰 고유번호숫자에 +1 더해서 담기 -> ref 한테 사용 
			if(rs.next()) forRef = rs.getInt(1) + 1; 
			else forRef = 1;  // 게시글이 하나도 없으면 ref 1로 지정 
			
			// 답글일때 
			if(num != 0) {
				// DB에 기존에 달린 답글 (re_step이 0보다 큰)이 있다면, 새답글이 1이 되기 위해
				// 기존에 저장된 답글의 step을 +1 해서 업데이트해주기. (최근 답글이 위로 올라오게)
				sql = "update board set re_step=re_step+1 where ref=? and re_step > ?"; 
				pstmt = conn.prepareStatement(sql);
				pstmt.setInt(1, ref);
				pstmt.setInt(2, re_step);
				pstmt.executeUpdate(); 
				// 답글은 DB에 저장하기전에, 받아온 초기값 0 에서 1이 되게 더해줌 
				re_step += 1;
				re_level += 1; 
			}else {
				// 새글 기본값 
				ref = forRef; 
				re_step = 0; // 생략가능
				re_level = 0; // 생략가능 ㅇ
			}
			
			sql = "insert into board values(board_seq.nextVal,?,?,?,?,?,?,?,?,?,?)";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, article.getWriter());
			pstmt.setString(2, article.getSubject());
			pstmt.setString(3, article.getEmail());
			pstmt.setString(4, article.getContent());
			pstmt.setString(5, article.getPw());
			pstmt.setTimestamp(6, article.getReg());
			pstmt.setInt(7, article.getReadcount());
			pstmt.setInt(8, ref);
			pstmt.setInt(9, re_step);
			pstmt.setInt(10, re_level);
			pstmt.executeUpdate();
			
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
	}
	
	// 글 고유번호 받아 해당 글 한개 가져오는 메서드 
	public BoardDTO getArticle(int num) {
		Connection conn = null; 
		PreparedStatement pstmt = null; 
		ResultSet rs = null;
		BoardDTO article = null; 
		
		try {
			conn = getConnection(); 
			// 해당 글 조회수 올리기 
			String sql = "update board set readcount=readcount+1 where num = ?"; 
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, num);
			pstmt.executeUpdate();
			
			// 해당 글 가져오기 
			sql = "select * from board where num = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, num);
			
			rs = pstmt.executeQuery(); 
			if(rs.next()) {
				article = new BoardDTO();
				article.setNum(num);
				article.setWriter(rs.getString("writer"));
				article.setSubject(rs.getString("subject"));
				article.setEmail(rs.getString("email"));
				article.setContent(rs.getString("content"));
				article.setPw(rs.getString("pw"));
				article.setReg(rs.getTimestamp("reg"));
				article.setReadcount(rs.getInt("readcount"));
				article.setRef(rs.getInt("ref"));
				article.setRe_level(rs.getInt("re_level"));
				article.setRe_step(rs.getInt("re_step"));
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return article;
	}
	
	// 게시글 수정 폼위해 해당 글 가져오기 
	public BoardDTO getUpdateArticle(int num) {
		BoardDTO article = null; 
		Connection conn = null; 
		PreparedStatement pstmt = null; 
		ResultSet rs = null; 
		try {
			conn = getConnection();
			String sql = "select * from board where num = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, num);
			
			rs = pstmt.executeQuery(); 
			if(rs.next()) {
				article = new BoardDTO(); 
				article.setNum(num);
				article.setWriter(rs.getString("writer"));
				article.setSubject(rs.getString("subject"));
				article.setEmail(rs.getString("email"));
				article.setContent(rs.getString("content"));
				article.setPw(rs.getString("pw"));
				article.setReg(rs.getTimestamp("reg"));
				article.setReadcount(rs.getInt("readcount"));
				article.setRef(rs.getInt("ref"));
				article.setRe_level(rs.getInt("re_level"));
				article.setRe_step(rs.getInt("re_step"));
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return article;
	}
	
	// 게시글 수정 처리 메서드 
	public int updateArticle(BoardDTO article) {
		Connection conn = null; 
		PreparedStatement pstmt = null; 
		ResultSet rs = null; 
		int result = 0; 
		try {
			conn = getConnection();
			
			// 비밀번호 확인 -> 비밀번호 오류/수정안됨 = 0, 비밀번호맞아서 수정되면 = 1 (executeUpdate()리턴값) 
			String sql = "select pw from board where num = ?"; 
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, article.getNum());
			rs = pstmt.executeQuery(); 
			if(rs.next()) {
				String dbpw = rs.getString("pw");
				if(dbpw.equals(article.getPw())) {
					// DB상 비번과 일치하면 업데이트 
					sql = "update board set writer=?, subject=?, email=?, content=? where num = ?";
					pstmt = conn.prepareStatement(sql);
					pstmt.setString(1, article.getWriter());
					pstmt.setString(2, article.getSubject());
					pstmt.setString(3, article.getEmail());
					pstmt.setString(4, article.getContent());
					pstmt.setInt(5, article.getNum());
					
					result = pstmt.executeUpdate(); // 하나의 레코드 업데이트 되면 1리턴 
				}
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return result;
	}
	
	// 게시글 삭제 처리 메서드 
	public int deleteArticle(int num, String pw) {
		int result = 0; 
		Connection conn = null; 
		PreparedStatement pstmt = null; 
		ResultSet rs = null; 
		try {
			conn = getConnection(); 
			// 비밀번호 확인 
			String sql = "select pw from board where num = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, num);
			
			rs = pstmt.executeQuery();
			if(rs.next()) {
				String dbpw = rs.getString("pw");
				if(dbpw.equals(pw)) {
					// 비밀번호 맞으면 데이터 삭제 
					sql = "delete from board where num = ?";
					pstmt = conn.prepareStatement(sql);
					pstmt.setInt(1, num);
					
					result = pstmt.executeUpdate(); // 삭제 잘 되었으면 1 리턴 
				}
			}
		}catch(Exception e) {
			e.printStackTrace();
		}finally {
			if(rs != null) try { rs.close(); } catch(Exception e) { e.printStackTrace();}
			if(pstmt != null) try { pstmt.close(); } catch(Exception e) { e.printStackTrace();}
			if(conn != null) try { conn.close(); } catch(Exception e) { e.printStackTrace();}
		}
		return result;
	}
	
	
	
	
	
	
	
	
	
	
}
