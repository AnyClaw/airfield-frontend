import { createRouter, createWebHistory } from 'vue-router'

import Planes from '../views/Planes.vue'
import Login from '../views/Login.vue'
import PlaneInfo from '../views/PlaneInfo.vue'
import Register from '@/views/Register.vue'
import PilotProfile from '@/views/PilotProfile.vue'

const routes = [
  {
    path: '/planes', 
    name: 'Planes',  
    component: Planes
  },
  {
    path: '/login',
    name: 'Login',
    component: Login
  },
  {
    path: '/planes/:id/:plane',
    name: 'PlaneInfo',
    component: PlaneInfo,
  },
  {
    path: '/register',
    name: 'Register',
    component: Register
  },
  {
    path: '/profile',
    name: 'Profile',
    component: PilotProfile
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router