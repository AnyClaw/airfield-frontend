<script setup>
import axios from 'axios';
import { useRoute } from 'vue-router'

import Header from '@/components/Header.vue';

const route = useRoute()

const id = route.params.id
const plane = route.params.plane
</script>

<template>
    <div>
        <Header/>
        <div>{{ id }}</div>
        <div>{{ plane }}</div>
    </div>
</template>

<style scoped>

</style>