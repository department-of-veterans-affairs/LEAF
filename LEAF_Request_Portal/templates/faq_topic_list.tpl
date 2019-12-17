
		
<style type="text/css">

	#dynamic-data-container{
		width:80%;
		height:60%;
		margin:auto;
	}
	
	#card-container{
		display:flex;
		justify-content:center;
		align-items:stretch;
		margin:auto;
		padding-top:20px;
		flex-wrap: wrap;
	}

	.faq-card{
		width: 20%;
		box-sizing: border-box;
		padding: 10px;
		vertical-align: middle;
	}
	
	.card-title{
		font-family: verdana;
		text-align: center;
		padding:5px 0px 5px 0px;
		font-size: 15px;
	}
	
	.card-image{
		display:block;
		height: 75px;
		width:  75px;
		margin:auto;
	}
	
	a{
		text-decoration:none;
		color: black;
	}
	
	#faq-search{
		display:flex;
		align-items:center;
		width:75%;
		padding:10px;
		margin:auto;
	}
	
	.faq-input-label{
		font-family: verdana;
		font-size: 15px;
		padding:6px 10px 6px 10px;
	}
	
	#faq-search-input{
		padding:4px;
		flex-grow:5;
	}
	
	#faq-search-icon{
		height:25px;
		width:25px;
		padding:6px 10px 6px 10px;
	}
	
	#faq-header{
		font-family: verdana;
		text-align:center;
		padding-top:15px;
	}
	
	#back-from-questions{
		font-family: verdana;
		padding-top:15px;
	}
	
	li{
		font-size: 15px;
		list-style-type: none;
		font-family: verdana;
		padding: 15px 10px 15px 10px;
	}
	
</style>


<div>
	<div id="dynamic-data-container">
		<div id="faq-category-list">
			<h2 id="faq-header">
				Select a topic
			</h2>
			<div id="card-container">
			
			    <!--{foreach $cardData as $item}-->
					<div class="faq-card" data-term="<!--{$item->faqType}-->">
						<a href="#" data-term="<!--{$item->faqType}-->">
							<img src="<!--{$item->imgUrl}-->" class="card-image"/>
							<div class="card-title">
								<!--{$item->title}-->
							</div>
						</a>
					</div>
				<!--{/foreach}-->
			</div>
		</div>
		
		<div id="faq-question-list" style="display:none">
			<a href="#"><h2 id="back-from-questions">&lt; Back</h2></a>
			<ul id="question-list-container">
			</ul>
		</div>
	</div>

	<form id="faq-search">
		<span class="faq-input-label">
			Search:
		</span>
		<input type="text" id="faq-search-input"/>
		<input type="image" id="faq-search-icon" src="../libs/dynicons/svg/search.svg"/>
	</form>


</div>

<script>

	$(document).ready(function(){
	
		$("#faq-search").submit(function(e){
			e.preventDefault();
			var term = $("#faq-search-input").val();
			
			if(term == null || term === ""){
				return;
			}
			
			getQuestions(term, false);
			
		});
	
		$(".faq-card").click(function(e){
			e.preventDefault();
			var term = $(this).data("term");
			
			getQuestions(term, true);
		});
		
		$("#back-from-questions").click(function(e){
			$("#faq-search-input").val('');
			$("#faq-question-list").fadeOut("fast", function(){
				$("#faq-category-list").fadeIn("fast");
			});
		});
		
		function getQuestions(term, byType){
			
			$.ajax({
				type:'GET',
				url:"ajaxIndex.php?a=faqquestions",
				data:{byType:byType, filterBy:term},
				success:function(response){

					displayQuestions($.parseJSON(response));
			
					$("#faq-category-list").fadeOut("fast", function(){
						$("#faq-question-list").fadeIn();
					});
				}
			});
		
		}
		
		function displayQuestions(questions){
		
			$("#question-list-container").empty();
		
			for(var i=0; i< questions.length; i++){

				debugger;
			
				var toDisplay = questions[i];
			
				var html = "<li><a href='"+toDisplay.url+"' class='question'>"+ toDisplay.title +"</a></li>";
			
				$("#question-list-container").append(html);
			
			}
		
		}
	
	});

</script>
