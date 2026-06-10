import re
from django.test import TestCase
from django.urls import reverse

class PingPongTests(TestCase):
    
    def test_ping_button_renders(self):
        response = self.client.get(reverse('home')) 
        self.assertContains(response, '<button id="pingButton">Ping</button>')

    def test_ping_endpoint(self):
        response = self.client.get(reverse('ping')) 
        self.assertEqual(response.status_code, 200)
        self.assertTrue(re.match(r'{"message": "pong [0-9\.]+"}', response.content.decode('utf-8')))

    def test_button_click_updates_response(self):
        response = self.client.get(reverse('home')) 
        response = self.client.get(reverse('ping'))  
        self.assertTrue(re.match(r'{"message": "pong [0-9\.]+"}', response.content.decode('utf-8')))
        print('Test change')
