import { createRouter, createWebHistory } from 'vue-router'

import Planes from '../views/Planes.vue'
import Auth from '../views/Auth.vue'

const routes = [
  {
    path: '/planes', 
    name: 'Planes',  
    component: Planes
  },
  {
    path: '/auth',
    name: 'Auth',
    component: Auth
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router