import os
import json
import requests
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated

DEEPSEEK_URL = "https://api.deepseek.com/v1/chat/completions"

def _call_deepseek(system_prompt: str, user_prompt: str):
    api_key = os.getenv("DEEPSEEK_API_KEY")
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "model": "deepseek-chat",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": 0.7,
        "max_tokens": 3000
    }

    try:
        response = requests.post(DEEPSEEK_URL, headers=headers, json=payload, timeout=30)
        response.raise_for_status()
        data = response.json()
        
        content = data['choices'][0]['message']['content'].strip()
        
        if content.startswith('```json'):
            content = content[7:]
        if content.startswith('```'):
            content = content[3:]
        if content.endswith('```'):
            content = content[:-3]
            
        return JsonResponse(json.loads(content.strip()), safe=False)
        
    except Exception as e:
        return JsonResponse({"detail": f"AI Error: {str(e)}"}, status=500)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_lesson_plan(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate a detailed lesson plan in JSON format with EXACTLY these keys: 'title', 'curriculum_alignment', 'learning_objectives' (list of objects with 'objective'), 'introduction', 'activities' (list of objects with 'duration', 'activity_title', 'description')."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_worksheet(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate a comprehensive worksheet in JSON format with keys: title, instructions, questions (list of objects with 'question', 'type', 'marks'). Include a mix of question types."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_quiz(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate a quiz in JSON format with keys: title, total_marks, duration_minutes, questions (list of objects with 'question', 'options' (list of 4), 'correct_answer', 'explanation'). Generate 10 MCQ questions."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_question_paper(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate a formal question paper in JSON format with keys: title, total_marks, duration, instructions (list), sections (list of objects with 'name', 'marks', 'questions' list). Include Section A (MCQ), B (Short Answer), C (Long Answer)."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_study_notes(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate comprehensive study notes in JSON format with keys: title, summary, key_concepts (list), detailed_notes (list of objects with 'heading' and 'content'), important_formulas (list), tips, practice_problems (list)."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_presentation_outline(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate a presentation outline in JSON format with keys: title, total_slides, slides (list of objects with 'slide_number', 'title', 'content' (list of bullet points), 'speaker_notes'). Create 10-12 slides."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)

@csrf_exempt
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_rubric(request):
    req = request.data
    system_prompt = "You are an expert educator. Generate an assessment rubric in JSON format with keys: title, criteria (list of objects with 'criterion', 'excellent', 'good', 'satisfactory', 'needs_improvement', 'weight'). Include 5-6 criteria."
    user_prompt = f"Subject: {req.get('subject')}\nGrade: {req.get('grade')}\nChapter: {req.get('chapter')}\nTopic: {req.get('topic')}"
    return _call_deepseek(system_prompt, user_prompt)
